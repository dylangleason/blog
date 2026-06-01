title: use-package and Leaky Abstractions
date: 2026-05-02 10:47
tags: code, emacs, lisp, tech
---

Emacs, being one of the oldest text editors under active development,
has accumulated a lot of warts. The first version of GNU Emacs was
[released](https://www.gnu.org/software/emacs/history.html) when this
author was only 1 year old.

Being a highly extensible, customizable, and full-fledged Lisp
environment, the codebase has evolved over decades, with thousands of
packages developed by both the GNU team and third-party contributors.

And, due to a recent renaissance in third-party development of Emacs
packages and significant internal improvements, such as built-in
support for
[`tree-sitter`](https://tree-sitter.github.io/tree-sitter/), native
compilation, and an
[LSP](https://www.gnu.org/software/emacs/manual/html_node/eglot/index.html)
client, Emacs is arguably more capable and more powerful than ever.

But along with all those capabilities, there's also fragmentation.
This is due to a combination of factors, including the competing
visions of the GNU Project and the broader open-source community, the
former's unique governance and contribution model, and the resulting
need for both official and unofficial package repositories.

This fragmentation becomes apparent to any Emacs user that has spent
any amount of time configuring their editor settings and maintaining
packages using Emacs Lisp.

## Package Configuration

Enter
[`use-package`](https://www.gnu.org/software/emacs/manual/html_mono/use-package.html).
While `use-package` wasn't meant to solve the fragmentation problem,
it's declarative approach to package configuration appears to offer a
uniform interface, something that was heretofore lacking. Perhaps,
maybe, it could limit the impact of a fragmented and disparate package
landscape.

### Terminology

First, a bit about Emacs packages. A _package_ is basically a
distribution of source code written in Emacs Lisp that can be
installed in an Emacs system. There are both internal packages bundled
with Emacs, and third-party packages that can be installed from
various repositories (more on that later). For example, `js` is an
internal package in Emacs that defines capabilities for editing,
modifying and interacting with JavaScript code.

A _feature_ is a symbol defined and `provide`d by a package, which a
consuming package or code can `require` to make use of those
capabilities. Think of features as analogous to a module or namespace
in another language, with some big caveats: it doesn't prevent name
collisions, and it's really just a naive source code loading mechanism
(no ability to selectively import or refer to specific symbols within
a package, no mechanism of encapsulation, etc.).

Here's a basic example illustrating a package definition for a
fictional package called `nice-package`:

```elisp
;; nice-package.el

;; Variable meant to be customized by the consumer of this
;; package. Note that symbols are prefixed with the package name,
;; in this case `nice-package'. This is an Emacs convention to avoid
;; name collisions, as Emacs does not implement namespaces or a proper
;; module system.
(defcustom nice-package-customizable-variable
  ;; ...
  )

;; Similarly, Emacs Lisp does not provide package encapsulation.
;; For definitions meant to be unexported, "--" is used to delimit
;; the package and function components of the name. This is just a
;; naming convention and has no effect on visibility.
(defun nice-package--unexported-function ()
  ;; ...
  )
  
(defun nice-package-interactive-function ()
  ;; ...
  )
  
;; Provide the feature so that others may use it.
(provide 'nice-package)
```

And here is some consumer elisp code loading the `nice-package`
feature so that it can be used within a user's Emacs session:

```elisp
;; init.el

;; ... other configuration here ...

(require 'nice-package)
```

### Basic Configuration

Configuring a package via `use-package` is pretty straightforward at
first. Often times, `use-package` is used to both configure and
_install_ the target package, due to its integration with
`package.el`.

For example, the following declaration both installs and configures
the `company` package:

```elisp
(use-package company)
```

Since `use-package` is a macro, we can expand the list form
appropriately using `macroexpand` to take a peek at what is going on
underneath the hood:

```elisp
(progn
  (straight-use-package 'company)
  (defvar use-package--warning105
    #'(lambda (keyword err)
        (let
            ((msg
              (format "%s/%s: %s" 'company keyword
                      (error-message-string err))))
          (display-warning 'use-package msg :error))))
  (condition-case-unless-debug err
      (if (not (require 'company nil t))
          (display-warning 'use-package
                           (format "Cannot load %s" 'company) :error))
    (error (funcall use-package--warning1 :catch err))))
```

Clearly, this is doing a lot of work for us. Let's break it down:

1. The first line in the `progn` block tells `use-package` to install
`company` via
[`straight.el`](https://github.com/radian-software/straight.el), which
is a third-party package manager. In my Emacs configuration, I have
enabled this behavior globally via `straight-use-package-by-default`.
2. Next, `use-package` defines a variable and sets it to a warning
callback, to display a warning when signaling an error condition.
3. Then, `use-package` attempts to load the `company` feature via
`require`, and handles any error conditions gracefully using the
`condition-case` special form. If an error condition occurs, the
warning callback function is executed to report the error.

That definitely eliminates a lot of boilerplate.

### Deferred Loading

Next, let's try adding a hook to enable company mode after Emacs
initializes. This can be accomplished by updating our declaration as
follows:

```elisp
(use-package company
  :hook (after-init . global-company-mode))
```

There's a couple more interesting bits to note with this updated
declaration:

1. A `:hook` declaration creates a `cons` cell, specifically a dotted
pair. Note the dotted pair isn't quoted.
2. The hook name is referenced as `after-init`, not `after-init-hook`,
the latter being the correct name for the hook function.

And here are the relevant changes from the expansion:

```elisp
(progn
  ;; same as before ...
  (condition-case-unless-debug err
      (progn
        (unless (fboundp 'global-company-mode)
          (autoload #'global-company-mode "company" nil t))
        (add-hook 'after-init-hook #'global-company-mode))
    ;; same as before ...
    ))
```

This looks mostly the same, except the `progn` in the body of the
`condition-case-unless-debug` handler is doing something noticeably
different than the first example.

1. Rather than using `require`, the code produced by the macro first
checks to see if the symbol `global-company-mode` is bound to a
function.
2. If said symbol is unbound, it registers an autoload function for it.
3. Lastly, it registers the `after-init-hook`. Note that `use-package`
added the `-hook` suffix.

When `global-company-mode` is first invoked by way of the
`after-init-hook`, Emacs uses the autoload registry to locate and
install the real definition for `global-company-mode`, as it is
defined in the `"company"` file.

This example illustrates how `use-package` implicitly uses a deferred
loading strategy based on the declaration of a hook. Using the
autoload registry and lazily loading packages in this fashion can
greatly reduce Emacs startup times and save memory.

You can enforce eager loading, e.g. via `:demand t` in a declaration,
which is sometimes needed for packages that need to be present at
startup.

## A Slow Trickle

The case of configuring hooks in `use-package` is relatively
straightforward, but for other scenarios timing between when certain
objects exist versus when `use-package` attempts to load them can
reveal cracks in `use-package`'s declarative facade.

### What Time Is It?

The first aspect of `use-package` that caused me confusion is the
various timing semantics. I am referring to the various methods of
initializing and configuring a package, such as `:init`, `:config`,
`:bind`, and `:hook`.

The case of `:init` is relatively straightforward, as Lisp defined in
it will be evaluated before a package loads, unconditionally. This is
commonly used for setting variables, for example via `setq`, that may
need to be in place prior to the package loading.

```elisp
;; TODO
```

Even here there are some subtleties to keep in mind. For example, if a
package defines an autoload function that is mistakenly called in the
context of an `:init` block, it will have the effect of loading the
package, perhaps before the user intended, losing the benefits of
deferred loading.

```elisp
;; TODO
```

Similarly,`:config` will evaluate any Lisp that follows after the
target package loads. For example, this might be useful for invoking
functions that are only defined after the target package load, but is
needed to configure the package according to the user's
preference. 

```elisp
;; TODO
```

The `use-package` documentation recommends using `:config` instead of
`:init` where possible, and further recommends using the autoloading
keywords in favor of either of the former two. But, this is precisely
where the complexity starts to reveal itself. And, because a lot of
the autoloading behavior is implied with `use-package`, it can make
things non-obvious and confusing.

### Hooks

```elisp
;; TODO
```

### Keybindings

Keybindings: so many ways to define them. Are they global, or
buffer-local?  Is it a custom keymap defined by a given mode? If so,
how is it defined? Then there is the question of which API to use.
Though, `use-package` promises simplifies this process in some ways,
as per usual you need to understand the way the target package exposes
autoloads and defines its keymaps to understand how to use them
effectively.

## Conclusion

While it largely does a commendable job at eliminating boilerplate, at
a certain point this declarative promise of `use-package` breaks
down. Due to fragmentation in how Emacs features are defined, a
mixture of different APIs and programming styles (declarative and
imperative) are often required with `use-package`.
