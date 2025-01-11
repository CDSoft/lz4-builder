-- This file is part of lz4-builder.
--
-- lz4-builder is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- lz4-builder is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with lz4-builder.  If not, see <https://www.gnu.org/licenses/>.
--
-- For further information about lz4-builder you can visit
-- https://github.com/CDSoft/lz4-builder

var "release" "2025-01-11"

var "lz4_version" "1.10.0"

help.name "lz4-builder"
help.description [[
Distribution of lz4 binaries for Linux, MacOS and Windows.

This Ninja build file will compile and install lz4 $lz4_version.
]]

local F = require "F"
local targets = require "targets"

var "builddir" ".build"
clean "$builddir"

var "tmp" "$builddir/tmp"
var "bin" "$builddir/bin"
var "all" "$builddir/all"

rule "extract" {
    description = "extract $url",
    command = "curl -fsSL $url | PATH=$bin:$$PATH tar x --$fmt",
}

local cflags = {
    "-O3",
    "-s",
    "-Ilz4-$lz4_version/lib",
}

local ldflags = {
    "-s",
}

build.cc : add "cflags" { cflags } : add "ldflags" { ldflags }
targets : foreach(function(target)
    build.zigcc[target.name] : add "cflags" { cflags } : add "ldflags" { ldflags }
end)

local host = {}         -- binaries for the current host compiled with cc/c++
local cross = targets   -- binaries for all supported platforms compiled with zig
    : map(function(target) return {target.name, {}} end)
    : from_list()

--------------------------------------------------------------------
section "lz4"
--------------------------------------------------------------------

var "lz4_url" "https://github.com/lz4/lz4/archive/refs/tags/v1.10.0.tar.gz"

local lz4_sources = {
    F.map(F.prefix("lz4-$lz4_version/programs/"), {
        "bench.c",
        "lorem.c",
        "lz4cli.c",
        "lz4io.c",
        "threadpool.c",
        "timefn.c",
        "util.c",
    }),
    F.map(F.prefix("lz4-$lz4_version/lib/"), {
        "lz4.c",
        "lz4file.c",
        "lz4frame.c",
        "lz4hc.c",
        "xxhash.c",
    }),
}

build(lz4_sources) { "extract", url="$lz4_url", fmt="gzip" }

local lz4 = build.cc "$bin/lz4" { lz4_sources }
acc(host) { lz4 }

targets : foreach(function(target)
    acc(cross[target.name]) {
        build.zigcc[target.name]("$all"/target.name/"lz4") { lz4_sources }
    }
end)

--------------------------------------------------------------------
section "Host binaries"
--------------------------------------------------------------------

phony "compile" { host }
help "compile" "Build Lz4 binaries for the host only"

default "compile"

install "bin" { host }

--------------------------------------------------------------------
section "Archives"
--------------------------------------------------------------------

rule "tar" {
    description = "tar $out",
    command = "tar -caf $out $in --transform='s,$prefix/,,'",
}

local archives = targets : map(function(target)
    return build("$builddir/lz4-build-${release}-"..target.name..".tar.gz") { "tar",
        cross[target.name],
        prefix = "$all"/target.name,
    }
end)

local release_note = build "$builddir/README.md" {
    description = "$out",
    command = {
        "(",
        'echo "# LZ4 ${release_date}";',
        'echo "";',
        'echo "| Program | Version | Documentation |";',
        'echo "| ------- | ------- | ------------- |";',
        'echo "| lz4 | [$lz4_version]($lz4_url) | <https://github.com/lz4/lz4> |";',
        ") > $out",
    },
}

phony "all" { archives, release_note }
help "all" "Build Lz4 archives for Linux, MacOS and Windows"
