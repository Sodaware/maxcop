' ------------------------------------------------------------------------------
' -- main.bmx
' --
' -- Main driver file for maxcop. Imports the application
' -- type and runs it. See core/app.bmx for the actual app.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- MAXCOP is free software; you can redistribute it and/or modify
' -- it under the terms of the GNU General Public License as published by
' -- the Free Software Foundation; either version 3 of the License, or
' -- (at your option) any later version.
' --
' -- MAXCOP is distributed in the hope that it will be useful,
' -- but WITHOUT ANY WARRANTY; without even the implied warranty of
' -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' -- GNU General Public License for more details.
' --
' -- You should have received a copy of the GNU General Public
' -- License along with MAXCOP (see the file COPYING for more details);
' -- If not, see <http://www.gnu.org/licenses/>.
' ------------------------------------------------------------------------------


Framework brl.basic
Import "core/app.bmx"

Local theApp:App = New App
theApp.run()
