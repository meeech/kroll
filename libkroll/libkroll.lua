--
-- This is not complete or tested, I just wrote the initial skeleton
-- Great reference to all possible commands and what they do: http://industriousone.com/reference
--

solution "LibKroll"
    configurations { "Release", "Debug" }
    location ( _OPTIONS["to"] )
    
    
project "LibKroll"
    targetname  "libkroll"
    language    "C++"
    kind        "SharedLib"
    flags       {"ExtraWarnings", "UNICODE"}    
    includedirs { "." }

    files 
    {
        "*.cpp", "*.h", 
        "config/*.cpp", "config/*.h",
        "binding/*.cpp", "config/*.h",
        "utils/*.cpp", "utils/*.h",
        "utils/poco/*.cpp", "utils/poco/*.h",
        "net/proxy_config.cpp", "net/*.h",
        "javascript/*.cpp", "javascript/*.h",
        "api/*.cpp", "api/*.h",
        "src/host/scripts.c"
    }

    excludes
    {
    }
        
    configuration "Debug"
        targetdir   "build/debug"
        defines     { "_DEBUG", "DEBUG" }
        flags       { "Symbols" }
        
    configuration "Release"
        targetdir   "build/release"
        defines     "NDEBUG"
        flags       { "OptimizeSpeed" }

    configuration "vs*"
        defines     { "_CRT_SECURE_NO_WARNINGS" }

    configuration "windows"
        target ("build/win")
        objdir ("build/win/obj")
        includedirs { "..\thirdparty-win32-x86-r31\**" } -- Path not verified, needs fixing
        libdirs     { "..\thirdparty-win32-x86-r32\**" }
        links       { 
            "Advapi32", "comctl32", "icuuc", "icuin", 
            "iphlpapi", "kernel32", "ole32", "oleaut32", 
            "pthreadVC2", "shell32", "shlwapi", "user32", 
            "winhttp" 
        }
        linkoptions { "/LTCG", "/INCREMENTAL:NO" }
        
        files       {
            "net/proxy_config_win32.cpp",
            "utils/win32/*.cpp", "utils/win32/*.h",
            "utils/unzip/*.cpp", "utils/unzip/*.h",
            "win32/*.cpp", "win32/*.h"
        
        }

    configuration "linux"
        target ("build/linux")
        objdir ("build/linux/obj")
        buildoptions { "`pkg-config --cflags --libs libxml-2.0 gtk+-2.0 gdk-2.0 glib-2.0 gthread-2.0`"
        links       { "pthread", "libsoup-2.4", "libproxy", "libgcrypt", "libgnutls" } 
        
        files       {
            "linux/*.cpp", "linux/*.h",
            "net/proxy_config_linux.cpp",
            "utils/linux/*.cpp", "utils/linux/*.h",
        }
        
    configuration "macosx"
        target ("build/osx")
        objdir ("build/osx/obj")
        links       { 
            "ssl", "crypto", 
            "Cocoa.framework", "SystemConfiguration.framework", "CoreServices.framework" 
        }
        linkoptions { "-install_name libkroll.dylib" }
        includedirs { "..\thirdparty-osx-i386-r7\**" }
        libdirs     { "..\thirdparty-osx-i386-r7\**" }
        
        files       {
            "utils/osx/*.mm", "utils/osx/*.h",
            "net/proxy_config_osx.mm",
        }
    
    configuration { "linux", "macosx" }
        files       {
            "utils/posix/*.cpp", "utils/posix/*.h",
        }
        
    configuration { "macosx", "gmake" }
        buildoptions { "-mmacosx-version-min=10.7" }
        linkoptions  { "-mmacosx-version-min=10.7" }



--
-- A more thorough cleanup.
--
if _ACTION == "clean" then
    os.rmdir("bin")
    os.rmdir("build")
end

--
-- Use the --to=path option to control where the project files get generated. I use
-- this to create project files for each supported toolset, each in their own folder,
-- in preparation for deployment.
--
newoption {
    trigger = "to",
    value   = "path",
    description = "Set the output location for the generated files"
}
