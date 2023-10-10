$file_paths = @{}
$modules = @{} 
$subroutines = @{}
$calls = @{}
$uses = @{}
$dependencies = @{}

gci -path ED\src *.f90 -re | % {
    $f = $_.Name;
    $file_paths[$f] = $_ | Resolve-Path -Relative | % {$_ -replace '.\\src\\ED', 'ED'}
}

$file_paths.Keys | % {
    $modules[$_] = @()
    $subroutines[$_] = @()
    $calls[$_] = @()
    $uses[$_] = @()
    $dependencies[$_] = @()
}


gci -path ED\src *.f90 -re | % {
    $f = $_.Name;
    $contents = gc $_
    
    $contents | ? {
        $_ -match '^[ \t]*module (?!procedure\b)(\w+)'
    } | % {
        $modules[$f] += $_ -replace '^[ \t]*module (.*)', '$1'
    };

    $contents | ? {
        $_ -match '^[ \t]*subroutine (\w+)'
    } | % {
            $subroutines[$f] += $_ -replace '^[ \t]*subroutine (\w+?)[\( ].*', '$1'
    };

    $contents | ? {
        $_ -match '^[ \t]*call (\w+)'
    } | % {
            $calls[$f] += $_ -replace '^[ \t]*call (\w+?)[\( ].*', '$1'
    };

    $contents | ? {
        $_ -match '^[ \t]*use (\w+)'
    } | % {
            $uses[$f] += $_ -replace '^[ \t]*use (\w+).*', '$1'
    };    
}

$file_paths.Keys | % {
    $k = $_
    $calls[$k] | % {
        $call = $_;
        $dependencies[$k] += $subroutines.Keys | ? {
            $subroutines[$_] -contains $call
        }
    };
    $uses[$k] | % {
        $use = $_;
        $dependencies[$k] += $modules.Keys | ? {
            $modules[$_] -contains $use
        }
    };   
}

$unique_dependencies = @{}
$dependencies.Keys | % {
    $k = $_
    $unique_dependencies[$_] = $dependencies[$_] | select -Unique | ? {$_ -ne $k}
}

$deps_complete = @{}

$file_paths.Keys | % {
    $k = $_;
    $deps_complete[$k] = @();
    $unique_dependencies[$k] | % {
        $deps_complete[$k] += $file_paths[$_]
    }
}
$deps2 = @{}
$deps_complete.Keys | % {($file_paths[$_] -replace 'f90', 'o') + ': ' + (($deps_complete[$_] | % {$_ -replace 'F90', 'o'}) -join ' ')} > deps.out


$all = $unique_dependencies.Keys | % {
    $k = $_;
    $deps = $unique_dependencies[$k] | % {$_ -replace '\..*', ''};
    $key_target = $k -replace '\..*', '';
    echo "add_multiple_dependencies(${key_target}, $($deps -join ' '))"
}