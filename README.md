# App Archetype

Code project template renderer

## Installation

Install the gem into your system:

```bash
gem build
gem install app_archetype*.gem
```

Once installed you'll need to create a template directory and set it in your environment:

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

## Usage

### Creating a template

Templates are a collection of files in the template folder with a manifest. The structure is thus:

```text
 - $ARCHETYPE_TEMPLATE_DIR
 | - my_template
 | - | - template/
 | - | - | - file.erb
 | - | - | - file2.txt
 | - | - manifest.json
```

Each template must include a manifest which has instructions necessary to render the template at run time. 

To create a blank template run the new command with the relative (from your template directory) path to your new template. For example to create a ruby gem you might:

```bash
archetype new ruby/gem # creates a template at $ARCHETYPE_TEMPLATE_DIR/ruby/gem

# or

archetype new ruby_gem # creates a template at $ARCHETYPE_TEMPLATE_DIR/ruby_gem

# or

archetype new ruby/gem/on_rails # creates a template at $ARCHETYPE_TEMPLATE_DIR/ruby/gem/on_rails

# etc.
```

#### Template Manifests

A manifest has a name, version and set of variables. A sample manifest looks like this:

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
    "foo": "bar",
  }
}
```

- `name` should be a unique name that identifies a manifest for you
- `version` should be the version of the template
- `metadata.app_archetype` is information about the manifest for the app archetype gem. `metadata.app_archetype.version` is required, and must be less than the version of the currently installed gem.
- `variables` is a schemaless object that you may use to provide variables at render time

##### Jsonnet support

If plain ol' JSON isn't quite enough for you - manifests can also be expressed in jsonnet language. This permits you to use functions and objects to generate your template manifest. All manifest.json/manifest.jsonnet files will be parsed as you might expect.

See [https://jsonnet.org/](https://jsonnet.org/) for more jsonnet documentation

#### Template Files

Templates are a collection of files within a folder. You may put any files you want in side the `/template` directory and when it comes time to use the template.

ERB templates or handlebar templates will be rendered using the variables specified in the manifest.json. Anything that's not ERB or HBS will be copied across to the destination as is.

You can include handlebars in file names, and like template files, the variables will be used to render the filenames.

### Rendering a Template

Adjust the template manifest to include the variables you want, and then run:

```bash
mkdir where_id_like_to_render
cd where_id_like_to_render
archetype render my_template
```

And the template will be rendered with the instructions in the manifest to the destinaton location as simple as that.

### Listing Templates

You can list the templates in your template directory at any time by running the list command:

```bash
archetype list
```

## Licence

This gem is not for redistribution
