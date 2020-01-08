# App Archetype

Code project template renderer

## Installation

Install the gem into your system:

```bash
gem build
gem install app_archetype*.gem
```

## Usage

### Creating a template

Templates are a collection of files within a folder. Static files (i.e. non .erb files/files without handlebars in the name) are copied as is.

When a file name includes handlebars (i.e. `{{var}}.rb`) the value `var`, specified in the manifest is rendered into the filename in the destination directory.

Any `.erb` files are rendered with variables as you would expect.

To create a template, simply create the files and use erb templates where you need the files to include variable information. You should also provide a json manifest of variables necessary to render the template.

### Rendering a template

The gem registers the `archetype` executable:

```bash
archetype -h
```

To render a template use the render command:

```bash
archetype render --template ./path/to/template --destination ./path/to/destination --manifest ./path/to/manifest.json
```

The above will render the files at `./path/to/template` to  `./path/to/destination` if the destination exists.

Variables can be specified within a JSON file and provided to the renderer through the `--manifest` flag. It is recommended that variables be managed this way.

Alternatively the final arguments in k:v,k:v format can be provided on the command line if the template only requires a few variables.

```bash
archetype render --template ./path/to/template --destination ./path/to/destination var_name:value,var2_name:value2
```

## Licence

This gem is not for redistribution
