title: Sandboxed AI Agents using Agent Circus
date: 2026-11-11 11:00
tags: ai, programming, emacs, security
---

Lately I have been using AI coding agents more frequently, and after
reading about notable incidents of "rogue" agents doing bad things, it
became increasingly apparent that I should take steps to improve my
security hygiene when using AI agents.

## Running AI Agents Locally

The security implications of running non-deterministic LLM systems
locally, which has access to my file system and the ability to
communicate to the internet, should have been an obvious red flag from
the start. But it is all too easy (and I include myself in this) to be
lulled into complacency based on thin assurances from AI vendors,
despite their inherent untrustworthiness.

I won't go through the points here—my friend Ian did a much better
job [writing about the problem](https://blog.ianwwagner.com/stop-playing-russian-roulette-with-coding-agents.html) 
than I ever could—but suffice it to say, I can do better. While Ian
took the approach of sandboxing his agents in a fully remote
development environment using FreeBSD jails (which, I gotta say, is
just really neat), I don't have the resources and hardware to do that
right now. Someday, perhaps, but for now I am stuck with a local
development environment.

## Containerizing Agent Harnesses

Since I am using macOS and not FreeBSD, I decided to investigate
running agents using containers. Docker is the most obvious solution
for hosting containers, but I have been curious about using
[Podman](https://podman.io/) because its containerization engine is
rootless and per-user by default, whereas Docker requires additional
configuration to run without root access.

While Docker for Mac uses a thin Linux virtualization layer to host
containers, and therefore the attack surface isn't as large as it
would be when running a rootful Docker daemon on Linux, it still runs
as a daemon with root privileges on the VM and can access privileged
resources on the host. Docker Sandboxes greatly improve upon this with
its daemon-per-sandbox isolation model, but each daemon still has root
privileges that could potentially exploit things like, oh, a path
resolution bug in VirtioFS that allows arbitrary [code execution](https://www.cve.org/CVERecord?id=CVE-2026-77179).

Admittedly, Podman on macOS isn't immune from the above vulnerability
(it also uses VirtioFS), but its rootless user model provides a
secondary line of defense. At any rate, I think I kinda sold myself on
trying Podman well before this point anyway since I hadn't really used
it much before and I didn't feel like installing Docker for Mac 😝.

In order to simplify configuring and running the sandbox for my agent
harness, I evaluated a couple of existing solutions. Since I am using Emacs
Agent Shell (see my earlier [post](emacs-as-an-agentic-coding-environment.html) 
describing how I set that up), I settled on [Agent Circus](https://github.com/Embedded-Focus/agent-circus), 
which integrates with the former using Agent Context Protocol.

## Testing Agent Circus

Before tackling the Emacs side, I wanted to give it a spin just using
the command line, which shouldn't be too hard. First I need to install
it, and since it is a Python application I will do so using `uv`, per
the `README` instructions:

```
uv tool install agent-circus
```

Next, time to test it out in a project. I build the Agent Circus image
in a test project, specifying Podman as the runtime environment:

```
agent-circus build --runtime podman
```

With that, I can run the Claude CLI using the following:

```
agent-circus exec --runtime podman claude-code -- claude
```

## Configuring Agent Circus

Agent Circus will seed its configuration from vendor directories like
`~/.claude`, `~/.codex`, and `~/.opencode`, including any auth
credentials contained therein. Agent Circus then copies each to a
per-project directory in `~/.local/state/agent-circus`, which in turn
gets mounted to the sandbox container for the given project. 

### Global config file

Beyond the default configuration, there are some additional bits I
need to configure via a TOML file. Agent Circus reads the global
config file at `${XDG_CONFIG_DIR:-$HOME/.config}/agent-circus/config.toml`:

``` toml
env_passthrough = ["CHUTES_API_KEY", "CLAUDE_CODE_OAUTH_TOKEN"]

[runtime]
engine = "podman"

[logging]
level = "DEBUG"
file = "/tmp/agent-circus.log"
```

Since Claude Code on macOS stores auth credentials via Keychain for
interactive sessions, it is simpler to generate an auth token and
export it to the host environment via `CLAUDE_CODE_OAUTH_TOKEN`, which
can then be forwarded to the container via the `env_passthrough`
setting. As of this writing, I am also evaluating Chutes AI using an
OpenCode agent, so I do the same for my `CHUTES_API_KEY`.

Also, given that Docker is the default runtime environment, I want to
set the runtime environment to Podman, so I do not have to specify the
podman option every time I need to run the `agent-circus` command.

Wrapping up the global config, I also specify a temporary log file
with `DEBUG` level logging so I can troubleshoot any issues running
the Agent Circus container.

### Project specific config

Additionally, if a project I am working on contains a secrets file
like `.env`, I want to elide its contents from the container. I can
add it to a `shadow` list via a config file, relative to the project,
and Agent Circus will create a bind mount to `/dev/null` on the
container. For example, I add the following to `.agent-shell/config.toml`:

``` toml
shadow = [".env", ".env.local"]
```

This way, if app secrets are managed differently for another project,
I can add different files to the `shadow` list. Neat!

## Configuring OpenCode

Before moving onto Emacs, since I also use OpenCode to interact with
both Chutes AI and my local Ollama server, I need to make some to the
OpenCode configuration in `~/.config/opencode/opencode.json`:

``` javascript
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "edit": "ask",
    "bash": "ask",
    "webfetch": "allow"
  },
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (Local)",
      "options": {
        "baseURL": "http://host.containers.internal:11434/v1"
      },
      "models": {
        "devstral-small-2:24b": {
          "name": "Devstral Small 2 24B"
        },
        "gemma4:26b": {
          "name": "Gemma 4 26B"
        },
        "qwen3.5:9b": {
          "name": "Qwen 3.5 9B"
        }
      }
    },
    "chutes": {
      "name": "Chutes",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "https://llm.chutes.ai/v1"
      },
      "settings": {
        "apiKey": "{env:CHUTES_API_KEY}"
      }
    }
  }
}
```

Note that the `baseURL` option for the local Ollama provider needs to
be set to that of the container's host DNS entry, since the container
needs to egress to the host in order to query the Ollama server. In
Podman this is set to `host.container.internal`.

And, while not specifically pertaining to Agent Circus, I set the
Chutes `apiKey` via the `CHUTES_API_KEY` environment variable I
described earlier for the Agent Circus config.

## Configuring Emacs

Now to integrate Emacs Agent Shell with Agent Circus to continue
working as I am used to. This is achieved by executing the relevant
ACP client within the Agent Circus container via `agent-circus
exec`—the same one I used from the command line test earlier.

### Setting the Agent Shell Command

In my Emacs `use-package` declaration for `agent-shell`, I need to
customize the `agent-shell-command-prefix` variable, which is a list
of strings representing the command line prefix. Unlike the default,
it should invoke `agent-circus` for the selected service provider:

``` emacs-lisp
(use-package agent-shell
  :config
  (defun my/agent-shell-command-prefix (buffer)
    (let* ((config (agent-shell-get-config buffer))
           (service
            (pcase (map-elt config :identifier)
              ('claude-code "claude-code")
              ('opencode "opencode")
              ('codex "codex")
              (_ "opencode"))))
      (list "agent-circus" "exec" service "--")))
  (setq agent-shell-command-prefix #'my/agent-shell-command-prefix))
```

I've only defined mappings for Claude Code, Codex and OpenCode (with
the latter being the default), but other providers supported by Agent
Shell can be handled via `pcase` in the same manner. Agent Shell will
append the relevant ACP client command based on the selected provider.

### Resolving Files Between Container and Host

In order to resolve files located on the host from the container (and
vice-a-versa), there is an additional bit of configuration that is
required. Agent Shell provides a feature called
`agent-shell-devcontainer` for this purpose. Specifically, I need to
add the following in the above `:config` clause:

``` emacs-lisp
(use-package agent-shell
  :config
  ;; rest of config from previous example goes here...
  (setq agent-shell-path-resolver-function 
        #'agent-shell-devcontainer-resolve-path))
```

Because Agent Circus mounts the project directory into `/workspace`, I
also need to create a file on the host within the file relative to the
project at `.devcontainer/devcontainer.json` with the following
key-value pair:

``` javascript
{
  "workspaceFolder": "/workspace"
}
```

This tells Agent Shell where to resolve the project root. Without it,
Agent Shell will attempt to resolve workspace files relative to
`/workspaces/<repository_name>`, which is incorrect for Agent Circus,
and the Agent Shell process will hang. As best as I can tell, there
isn't a way to override this behavior on either end.

As an aside, I was able to troubleshoot and verify the above issue by
enabling ACP debug logs via `(setq acp-logging-enabled t)`, which
causes the ACP process to log debug data to a separate buffer. In my
case, it indicated that the dev container file was not found at the
expected path, right after the protocol handshake. In fairness, the
Agent Shell README identifies where it looks for the workspace—a more
thorough reading would have possibly saved me some time here 😅.

While this works, adding such boilerplate to every project is a bit
annoying. Fortunately, the Agent Circus author kindly wrote a useful
Elisp example for a [custom resolver](https://github.com/Embedded-Focus/agent-circus#emacs)
function that will automatically discover the container workspace and
resolve files in either direction, obviating the need to create the
above file for every project.

## Other Considerations

There are a couple of other things I have not done, like allowing the
agent browser access to the web browser on the host (using the same
DNS entry to resolve the local Ollama server), nor have I configured
SSH forwarding for accessing the remote Git repository within the
container. I probably won't do the latter, as I prefer to push and
otherwise manage Git remotes myself.

I also haven't dug into the network egress control mechanism Agent
Circus implements outside of the README claim of a "built-in firewall
restrict[ing] outbound network access to known-good destinations",
which is also probably something I should verify before getting too
comfortable.

## Conclusion

So far, the switch to a sandboxed environment using Agent Circus and
Podman has been pretty transparent. The former's ACP-enabled
integration with Agent Shell allows me to continue with my preferred
workflow, while also raising the security floor for my agentic
development habits. While it's not a bulletproof solution (nothing is,
short of eschewing agents completely or turning off the internet,
perhaps), it is certainly an improvement.
