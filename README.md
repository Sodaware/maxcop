# maxcop

![GPLv3](https://img.shields.io/github/license/Sodaware/maxcop.svg)
![GitHub release](https://img.shields.io/github/release/Sodaware/maxcop.svg)


A work-in-progress attempt at a BlitzMax source code checker.

![maxcop in action](https://www.sodaware.net/assets/images/projects/maxcop/maxcop-screenshot.png)


## Quick Links

Project Homepage:
: https://www.sodaware.net/maxcop/

Source Code
: https://github.com/sodaware/maxcop/


## Installation

1. Download a binary release from the maxcop homepage.
2. Extract the archive somewhere
3. Add the directory to your `PATH` variable *or* copy the binary file to a
   directory in your `PATH` (e.g. `/usr/local/bin/` on a GNU/Linux system).

All done! You'll now be able to run `maxcop` from the command line and start
scanning.


## Building

**maxcop** depends on the following modules:

  - [cower.bmxlexer](https://github.com/sodaware/cower.bmxlexer)
  - sodaware.blitzmax_array
  - sodaware.blitzmax_ascii
  - sodaware.console_color
  - sodaware.console_commandline
  - sodaware.file_config
  - sodaware.file_config_iniserializer
  - sodaware.file_config_sodaserializer
  - sodaware.file_fnmatch
  - sodaware.file_util

All sodaware modules are available in
[sodaware.mod](https://www.sodaware.net/sodaware.mod/).

**note** - the official version of
[cower.bmxlexer](https://github.com/nilium/cower.bmxlexer) is missing some
keywords used by maxcop and won't compile correctly. The linked fork
([sodaware/cower.bmxlexer](https://github.com/sodaware/cower.bmxlexer)) contains
the correct keyword list.


## Basic Usage

Running `maxcop` in your project folder will perform a complete scan of any BMX
source files.

**maxcop** also supports passing one or more files or directories.

```bash
maxcop src my_file.bmx
```

## Configuring Rules

`maxcop` searches the directory of the current file for a `maxcop_rules.ini` or
`.maxcop.ini` file. If one is not found, `maxcop` will search upwards until it
finds a rules files, or until the root directory is reached.

Local rules file override any other rules in the project.

Rules can be disabled by including their full name and setting `enabled` to
`false`:

```ini
[style/type_name_prefix]
enabled=false
```

Rule options can be set in a similar way.

```ini
[metrics/line_length]
max_line_length=80
```


## Available Rules

All rules are enabled by default.

### Lint

#### EmptyCaseRule

**name**: lint/empty_case

Raised if there is an empty `Case` statement in code.

```blitzmax
' Bad
Select value
    Case True
End Select

' Good
Select value
    Case True
        doThis()
End Select
```

#### EmptyElseRule

**name**: lint/empty_else

Raised if there is an empty `Else` statement in code.

```blitzmax
' Bad
If true Then
    doThis()
Else
EndIf

' Good
If true Then
    doThis()
EndIf
```

#### EmptySelectRule

**name**: lint/empty_select

Raised if there is an empty `Select` statement in code.

```blitzmax
' Bad
Select something
End Select

' Good
Select something
    Default
        doThis()
End Select
```

#### HandleExceptionsRule

**name**: lint/handle_exceptions

Raised if there is a Catch block without a variable.

```blitzmax
' Bad
Try
    doThis()
Catch
End Try

' Good
Try
    doThis()
Catch e:Exception
    Print "Something broke"
End Try
```

### Metrics

#### FunctionParameterCountRule

**name**: metrics/function\_parameter\_count

**options**:
  - `max_parameter_count` : Maximum number of parameters allowed.

Check that a function has under a certain number of parameters. Defaults to 5.

#### LineLengthRule

**name**: metrics/line_length

**options**:
  - `max_line_length` : Maximum line length

Checks a line is under a certain number of characters long. Defaults to 120.

#### MethodLengthRule

**name**: metrics/method_length

**options**:
  - `max_line_count` : Maximum number of lines allowed.

Checks a method has under a certain number of code lines inside. Defaults to 35.

#### MethodParameterCountRule

**name**: metrics/method\_parameter\_count

**options**:
  - `max_parameter_count` : Maximum number of parameters allowed.

Check that a method has under a certain number of parameters. Defaults to 5.

#### TrailingWhitespaceRule

**name**: metrics/trailing_whitespace

Checks there is no empty whitespace at the end of lines.

#### TypeFieldCountRule

**name**: metrics/type\_field\_count

**options**:
  - `max_field_count` : Maximum number of fields allowed in a type.

Checks a type has under a certain number of fields. Defaults to 15.

#### TypeFunctionCountRule

**name**: metrics/type\_function\_count

**options**:
  - `max_function_count` : Maximum number of functions allowed in a type.

Checks a type has under a certain number of functions. Defaults to 15.

#### TypeMethodCountRule

**name**: metrics/type\_method\_count

**options**:
  - `max_method_count` : Maximum number of methods allowed in a type.

Checks a type has under a certain number of methods. Defaults to 15.

### Style

#### FieldNamePrefixRule

**name**: style/field\_name\_prefix

Checks that pseudo-private field names do not start with `m_`. Should use `_`
prefix instead.

#### PrivateFieldNameCaseRule

**name**: style/private_field_name_case

Check the first letter of a pseudo-private field name starts with a lower-case
letter.

```blitzmax
' Bad
Field _SomeField:String

' Good
Field _someField:String
```

#### SpaceAfterCommaRule

**name**: style/space_after_comma

Check there is a space after comma characters.

```blitzmax
' Bad
doThis(1,2,3)

' Good
doThis(1, 2, 3)
```

#### SpaceAroundOperatorRule

**name**: style/space_around_operator

Check numeric operators (`=`, `+`, `-`, `/` and `*`) are surrounded by spaces.

```blitzmax
' Bad
x=1+2

' Good
x = 1 + 2
```

#### StringExceptionsRule

**name**: style/string_exceptions

Check that thrown exceptions are a Type, not a plain string.

```blitzmax
' Bad
throw "Something went wrong"

' Good
throw new SomethingWentWrongException
```

#### TypeMethodNameCaseRule

**name**: style/type_method_name_case

Check type methods begin with a lower case letter.

#### TypeNamePrefixRule

**name**: style/type_name_prefix

Check type names begin with `T`.

```blitzmax
' Bad
Type MyType

' Good
Type TMyType
```

#### TypeNameSuffixRule

**name**: style/type_name_suffix

**options**:
  - `suffix` : The suffix to check for.


Check type names end with the configured suffix. This rule is disabled by
default and requires a `suffix` value to be set.

```blitzmax
' With `suffix` set to "Object"

' Bad
Type Something

' Good
Type SomethingObject
```

#### UppercaseConstantsRule

**name**: style/uppercase_constants

Check constants are entirely uppercase.

```blitzmax
' Bad
Const Something_Here:String = "a"

' Good
Const SOMETHING_HERE:String = "a"
```


## Optional configuration

To enable scanning of modules, **maxcop** needs to configured with the correct
module paths. **maxcop** will look for an ini file in the following places:

- `~/.maxcoprc`
- `~/.config/maxcop.ini`
- `~/.config/maxcop/config.ini`
- `maxcop.ini` in the maxcop executable directory


An example configuration file looks something like this (replacing the full
paths with ones for your system):

```ini
[mod_path]
win32 = c:\full\path\to\blitzmax\mods\
linux = /full/path/to/blitzmax/mods/
macos = /full/path/to/blitzmax/mods/
```

This step is only required if you wish to scan modules by name (e.g. `maxcop
brl.basic`) instead of with an absolute path.
