' ------------------------------------------------------------
' -- main.bmx
' --
' -- Main driver file for maxcop. Imports the application
' -- type and runs it. See core/app.bmx for the actual app.
' ------------------------------------------------------------


SuperStrict
 
Framework brl.basic
Import "core/app.bmx"

Local theApp:App = New App
theApp.run()