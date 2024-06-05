defmodule Husky.Script do
  @moduledoc """
  Struct to represent a [git hook script](https://git-scm.com/docs/githooks)
  """
  require Husky.Util
  alias Husky.Script
  alias Husky.Util

  defstruct path: nil, content: nil

  def new(hook) when is_binary(hook) do
    %Script{path: Path.join(Util.git_hooks_directory(), hook)}
  end

  def add_content(%Script{} = script) do
    content = """
    #!/usr/bin/env sh
    # #{Util.app()}
    # #{Util.version()} #{
      :os.type()
      |> Tuple.to_list()
      |> Enum.map(&Atom.to_string/1)
      |> Enum.map(&(&1 <> " "))
    }
    #{if Mix.env() == :test, do: "export MIX_ENV=test && cd ../../"}
    SCRIPT_PATH=\"#{Util.escript_path()}\"
    HOOK_NAME=`basename \"$0\"`
    GIT_PARAMS=\"$*\"

    if [ \"${HUSKY_SKIP_HOOKS}\" = \"true\" ] || [ \"${HUSKY_SKIP_HOOKS}\" = \"1\" ]; then
      printf \"\\033[33mhusky > skipping git hooks because environment variable HUSKY_SKIP_HOOKS is set...\\033[0m\n\"
      exit 0
    fi

    if [ \"${HUSKY_DEBUG}\" = \"true\" ]; then
      echo \"husky:debug $HOOK_NAME hook started...\"
      echo \"husky:debug SCRIPT_PATH: $SCRIPT_PATH \"
      echo \"husky:debug HOOK_NAME: $HOOK_NAME \"
      echo \"husky:debug GIT_PARAMS: $GIT_PARAMS \"
    fi

    if [ -f $SCRIPT_PATH ]; then
      $SCRIPT_PATH $HOOK_NAME \"$GIT_PARAMS\"
    else
      echo \"Can not find Husky escript. Skipping $HOOK_NAME hook\"
      echo \"You can reinstall husky by running mix husky.install\"
    fi
    """

    %Script{script | content: content}
  end
end
