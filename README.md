# App Archetype

[![Ruby](https://github.com/andrewbigger/app_archetype/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/andrewbigger/app_archetype/actions/workflows/build.yml)

Code project template renderer

## Installation

This is best run as a CLI tool installed into your system:

```bash
gem install app_archetype
```

For inclusion in another script or application, add this line to your application's Gemfile:

```ruby
gem 'app_archetype'
```

## Getting Started

### Setting up your environment for CLI use

If installed as a system gem, you'll need to create a template directory and set it in your environment:

```bash
mkdir $HOME/Code/templates

# zshrc
echo '# App Archetype:' >> $HOME/.zshrc
echo 'export ARCHETYPE_TEMPLATE_DIR="$HOME/Code/templates"' >> $HOME/.zshrc

# bash
echo '# App Archetype:' >> $HOME/.bashrc
echo 'export ARCHETYPE_TEMPLATE_DIR="$HOME/Code/templates"' >> $HOME/.bashrc
```

Finally you'll need to set a editor environment variable for viewing files from app archetype:

```bash
# zshrc
echo 'export ARCHETYPE_EDITOR="vi"' >> $HOME/.zshrc # sets vim as default editor

# bash
echo 'export ARCHETYPE_EDITOR="vi"' >> $HOME/.bashrc # sets vim as default editor
```

### Use in another project/script (standalone)

An alternative method of usage is to create standalone ruby scripts for standalone exection (outside of the `ARCHETYPE_TEMPLATE_DIR`). As an example, the following describes a code component renderer, where a command class for a simple CLI application can be rendered automatically.

For this example you may wish to introduce a `scripts` folder to a project:

```bash
mkdir path/to/my_project/scripts
```

And under that make an archetypes template directory:

```text
 - 📁 path/to/my_project/scripts
 | - 📁 generators/
 | - | - 📁 command/
 | - | - | - 📁 template/
 | - | - | - | - 📁 lib/
 | - | - | - | - | 📁 app_archetype/
 | - | - | - | - | - | 📁 commands/
 | - | - | - | - | - | - | 📄 {{command_name.snake_case}}.rb.hbs
 | - | - | - 📄 manifest.json
 | - | 📄 create_new_command
```

A standalone generator can be written using the standalone render method exposed in the `AppArchetype` namespace. The following would be the content of the `create_new_command` script.

```ruby
#!/usr/bin/env ruby

require 'app_archetype'

puts 'CREATE NEW COMMAND'

manifest = AppArchetype.render_template(
  collection_dir: File.join(__dir__, 'generators'),
  template_name: 'command',
  destination_path: File.expand_path(File.join(__dir__, '..'))
)

puts <<~NEXT_STEPS
  ✔ Command created

  TODO:
NEXT_STEPS

manifest.next_steps.each do |step|
  puts step
end
```

## Usage

### Creating a template

Templates are a collection of files in the template folder with a manifest. The structure is thus:

```text
 - 📁 $ARCHETYPE_TEMPLATE_DIR
 | - 📁 my_template
 | - | - 📁 template/
 | - | - | - 📄 file.erb
 | - | - | - 📄 file2.txt
 | - | - 📄 manifest.json
```

To create a blank template like the one above in the `ARCHETYPE_TEMPLATE_DIR` run:

```bash
archetype new
```

#### Template Manifests

Template manifests describe what should be done with a template at render time. For more detailed documentation on the AppArchetype manifest schema see [https://docs.biggerconcept.com/app_archetype/templates/manifest/](https://docs.biggerconcept.com/app_archetype/templates/manifest/) for more detail, however as a brief overview, a manifest has a name, version and set of variables. A sample manifest looks like this:

```json
{
  "name": "my_template",
  "version": "0.1.1",
  "metadata": {
    "app_archetype": {
      "version": "0.1.2"
    }
  },
  "variables": {
    "foo": {
      "type": "string",
      "default": "bar"
    }
  },
  "next_steps": [
    "TODO:",
    "Restart your machine"
  ]
}
```

- `name` should be a unique name that identifies a manifest for you
- `version` should be the version of the template
- `metadata.app_archetype` is information about the manifest for the app archetype gem. `metadata.app_archetype.version` is required, and must be less than the version of the currently installed gem.
- `variables` is an object of variable descriptions
- `next_steps` is an array of human readable instructions on what to do after the manifest has been applied

#### Variable Descriptions

Variable descriptions looks like this:

```json
{
  "variables": {
    "foo": {
      "type": "string",
      "description": "An example string",
      "default": "bar"
    },
  }
}
```

Below is a description of the supported attributes in a variable definition:

- `type` (required) specifies the type of the variable. This can be one of `string`, `boolean`, `integer` or `map`
- `description` (recommended) a short string that describes to the user what the variable is going to be usef for
- `default` (optional) allows you to specify a default that is selected as the value when the user enters nothing into the prompt
- `value` (optional) when set the user will not be prompted for a value when the template is being generated

##### Jsonnet support

If plain ol' JSON isn't quite enough for you - manifests can also be expressed in jsonnet language. This permits you to use functions and objects to generate your template manifest. All manifest.json/manifest.jsonnet files will be parsed as you might expect.

See [https://jsonnet.org/](https://jsonnet.org/) for more jsonnet documentation

#### Template Folder

Templates are a collection of files within a folder. You may put any files you want in side the `/template` directory and when it comes time to use the template.

ERB templates or handlebar templates (HBS) will be rendered using the variables specified in the manifest.json. Anything that's not ERB or HBS will be copied across to the destination as is.

You can include handlebars in file names, and like template files, the variables will be used to render the filenames. See [https://docs.biggerconcept.com/app_archetype/templates/folder/](https://docs.biggerconcept.com/app_archetype/templates/folder/) for more detailed information about template folders.

#### Variable Supporting Functions

AppArchetype exposes functions to either further parse the value of a variable or generate data as a value of a variable. The use cases are subtly different, but can be described in the following groups:

- [Generator Functions](https://docs.biggerconcept.com/app_archetype/templates/functions/generators/) useful for generating data for use within filenames and template files
- [Helper Functions](https://docs.biggerconcept.com/app_archetype/templates/functions/helpers/) useful for parsing values provided for variables.

See the supporting documentation for more specifid information about supporting functions.

### Using the CLI

When setup with a template directory and when installed into the system, app archetype has the following commands:

- `render` - Renders a template to the current location
- `list` - Prints a list of known templates to STDOUT
- `find` - Searches for a template by name
- `open` - Opens manifest of template in `ARCHETYPE_EDITOR` process
- `new` - Creates a new blank template in `ARCHETYPE_TEMPLATE_DIR`
- `delete` - Deletes template and manifest from `ARCHETYPE_TEMPLATE_DIR`
- `variables` - Prints list of known variables from a manifest
- `path` - Prints path to `ARCHETYPE_TEMPLATE_DIR` to STDOUT
- `version` - Prints gem version to STDOUT
- `help` - Provides help on any of the above commands

You will find detailed usage instructions of all commands here: [https://docs.biggerconcept.com/app_archetype/commands/](https://docs.biggerconcept.com/app_archetype/commands/)

### Rendering a Template

The [`archetype render`](https://docs.biggerconcept.com/app_archetype/commands/render/) command will render a template from the `ARCHETYPE_TEMPLATE_DIR` to the current CLI location.

It supports an optional `--name` parameter that refers to the name of the template to render, when this is not provided, the tool will present a list of known templates.

To use:

```bash
mkdir where_id_like_to_render
cd where_id_like_to_render
archetype render --name my_template
```

### Listing Templates

You can list the templates in your template directory at any time by running the [`archetype list`](https://docs.biggerconcept.com/app_archetype/commands/list/) command:

```bash
archetype list
```

You will see a summary of known templates similar to this:

```text
NAME                        VERSION
go_module                   2.0.1  
bash_script                 1.0.0  
ruby_cli_gem                1.0.0  
```

### Finding Templates

You can search known templates in your template directory using the [`archetype find`](https://docs.biggerconcept.com/app_archetype/commands/find/) command:

```bash
archetype find --name bash
```

You will be presented with a list of templates that include the given name:

```text
NAME                        VERSION
bash_script                 1.0.0  
```

### Opening Template Manifest

If you have your `ARCHETYPE_EDITOR` variable set in your environment. You can use the [`archetype open`](https://docs.biggerconcept.com/app_archetype/commands/open/) command to open the manifest in a new editor process (for example `vi`).

Similar to the `archetype find` command, you may provide a name option to choose the manifest:

```bash
archetype open --name bash_script
```

### Creating a new Template

The [`archetype new`](https://docs.biggerconcept.com/app_archetype/commands/new/) renders a new blank template into the `ARCHETYPE_TEMPLATE_DIR` location.

Simply run:

```bash
archetype new
```

And follow the prompts.

### Deleting an existing template

You can delete a template manifest and its files by running the [`archetype delete`](https://docs.biggerconcept.com/app_archetype/commands/delete/) command. 

```bash
archetype delete --name bash_script
```

### Help and configuration

The Gem provides 2 commands to inspect its config. They are:

- [`archetype path`](https://docs.biggerconcept.com/app_archetype/commands/path/) which displays the currently configured `ARCHETYPE_TEMPLATE_DIR`
- [`archetype version`](https://docs.biggerconcept.com/app_archetype/commands/version/) which displays the current installed gem version

Additionally the [`archetype help`](https://docs.biggerconcept.com/app_archetype/commands/help/) provides more detailed usage information about all of the above mentioned commands.

## Contributing

See CONTRIBUTING.md for more information

## Licence

This gem is covered by the terms of the MIT licence. See LICENCE for more information
