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

MaxCop searches the current directory for a `maxcop_rules.ini` file.

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

#### TrailingWhitespaceRule

**name**: metrics/trailing_whitespace

Checks there is no empty whitespace at the end of lines.

#### TypeFunctionCountRule

**name**: metrics/type_function_count

**options**:
  - `max_function_count` : Maximum number of functions allowed in a type.

Checks a type has under a certain number of functions. Defaults to 15.

#### TypeMethodCountRule

**name**: metrics/type_function_count

**options**:
  - `max_method_count` : Maximum number of methods allowed in a type.

Checks a type has under a certain number of methods. Defaults to 15.

### Style

#### FieldNamePrefixRule

**name**: style/field_name_prefix

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
module paths.

Create a file called "maxcop.ini" in the same directory as maxcop. An example
would look something like this (replacing the full paths with ones for your
system):

```ini
[mod_path]
win32 = c:\full\path\to\blitzmax\mods\
linux = /full/path/to/blitzmax/mods/
macos = /full/path/to/blitzmax/mods/
```

This step is only required if you wish to scan modules by name (e.g. `maxcop
brl.basic`) instead of with an absolute path.
