{
  description = "Recharged: package and build environment (see docs/BUILDING.md)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      perSystem = f: nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ]
        (system: f nixpkgs.legacyPackages.${system});

      # The Linux packages of .github/workflows/build.yml.
      libsOf = pkgs: with pkgs; [
        alsa-lib libpulseaudio
        libx11 libxcb libxext libxrandr libxcursor libxi libxfixes libxscrnsaver libxtst libGL
        wayland libxkbcommon wayland-protocols libdecor
        udev dbus vulkan-loader vulkan-headers
      ];
      toolsOf = pkgs: with pkgs; [
        cmake ninja python3 git cargo rustc gnumake tcl-8_6 pkg-config wayland-scanner
      ];

      # The submodules tools/setup_dependencies.py initializes on Linux, at the
      # commits `git submodule status` records (nested ones: the same command
      # in extern/dawn and extern/freetype). Update a pin here with its
      # gitlink: set hash to "" and `nix build` prints the new one.
      github = repo: rev: hash: { url = "https://github.com/${repo}.git"; inherit rev hash; };
      chromium = repo: rev: hash: { url = "https://chromium.googlesource.com/${repo}"; inherit rev hash; };
      pins = {
        "extern/mscharged-decomp" = github "yannicksuter/mscharged-decomp" "8b9d92dd88b4c727cc6359ee4cd5ba128cced7b8" "sha256-WOwDwUaseYvfmSv8bBHt5/8mvALurg5X8cWIbgnVxws=";
        "extern/aurora" = github "encounter/aurora" "d664382f57002fbff143911c81b06b7e7a4b3ab4" "sha256-xcSHjph8jhLgY2kgsgLqyDRYxb9QEKQVN8gIz/JGulc=";
        "extern/corrosion" = github "corrosion-rs/corrosion" "1499b14e4906a2890f5cee1547c8848db261753d" "sha256-0m9vvAjyG4ot9IaPAvc1Trqq/u0PhYo0Zqu5HUnaiUk=";
        "extern/fmt" = github "fmtlib/fmt" "407c905e45ad75fc29bf0f9bb7c5c2fd3475976f" "sha256-BPzvhvKx4OSJ4QU40288AYY9NMANwHxkypnHgtfUayw=";
        "extern/imgui" = github "ocornut/imgui" "4806a1924ff6181180bf5e4b8b79ab4394118875" "sha256-sFOwMVn7XoCCtIVax8FU+nrbAZiw/FpAakZQuabl8+Y=";
        "extern/libpng" = github "pnggroup/libpng" "3061454d980de7d53608f594194cfac722721d2a" "sha256-CxQfe7fFANRhT5OOa3ywXdEcpNFfiaHNmfx/bwugD+g=";
        "extern/nod" = github "encounter/nod" "ebd80cac99b48a323200d84365e07a58cc27412d" "sha256-xjv2GrWEvg2MyNYnrIH5dXhMXKnG9ug7l/6MTWYv0Qc=";
        "extern/sdl" = github "libsdl-org/SDL" "8e37db5e797b6167f3a00d697d816a684bd259c7" "sha256-ExgDjifPSwwtcxMWQvBhBPaXZasB6CHnz8DRfFe49t8=";
        "extern/sqlite" = github "sqlite/sqlite" "a5333afb9ad1aa473f8963b92caeaa955f47dc74" "sha256-rjesLRMl/djrloZUJTDiR6AxKO9tJCI2hnAbgd2wSaI=";
        "extern/tracy" = github "wolfpld/tracy" "30997d5ca6bb632cc10807a1da8a6d3de0aeeb3c" "sha256-siRBsbU8RdwuIclNUydcho2PmgO32P4rP1ncSC+v5So=";
        "extern/xxhash" = github "Cyan4973/xxHash" "e626a72bc2321cd320e953a0ccf1584cad60f363" "sha256-G7iBzyESWdmqgyxgGRzWyniOvCNOStSxjZUHFdWuHUc=";
        "extern/zlib-ng" = github "zlib-ng/zlib-ng" "12731092979c6d07f42da27da673a9f6c7b13586" "sha256-LKqyG4XnbiwBgwkKfsyN7wbWA9crOv84eEvtRJbhWRE=";
        "extern/zstd" = github "facebook/zstd" "f8745da6ff1ad1e7bab384bd1f9d742439278e99" "sha256-YVpgIrmEM8zb+rukdpvQiXh2+3LOyAXseopPZ1EqW5U=";
        "extern/freetype" = github "freetype/freetype" "0a0221a1347e2f1e07c395263540026e9a0aa7c7" "sha256-x2TpYcbOXDLSEjHGXKMubsDY246qXy/60fJZPB2gnZY=";
        "extern/freetype/subprojects/dlg" = github "nyorain/dlg" "395ccad2c1e0daae535c4d20bb0a3f2424648e17" "sha256-N4hyPlehX0+I3eS9uNy/RhvJxQJGD0rLtz9yTLDm3wk=";
        "extern/dawn" = github "encounter/dawn" "1155e0ed531126f33a1279afa029349651ca1c93" "sha256-tMqIkw7YVJ4vYgW2bWi8FTZvKHog3PuGP5U32++j5kw=";
        "extern/dawn/third_party/abseil-cpp" = chromium "chromium/src/third_party/abseil-cpp" "df548c50b2cda67158364d3d23c63043881b391d" "sha256-OCrB5s3KQIV0Dt1tLhOx67XcadOIOkkJZzRYrUwf4Dg=";
        "extern/dawn/third_party/jinja2" = chromium "chromium/src/third_party/jinja2" "c3027d884967773057bf74b957e3fea87e5df4d7" "sha256-4qz/GDwN4NJj3Npa2BOw4S1UxBfkSNDlBKdotAM6krU=";
        "extern/dawn/third_party/markupsafe" = chromium "chromium/src/third_party/markupsafe" "4256084ae14175d38a3ff7d739dca83ae49ccec6" "sha256-3RUpNEi2TjXmt8JDrmAkTUupBtsfBW7bj/W70ykuKOM=";
        "extern/dawn/third_party/spirv-headers/src" = chromium "external/github.com/KhronosGroup/SPIRV-Headers" "942fe4b988359a0750b79f0ae7ed735994d3147d" "sha256-29ZWB8JLVxpRa4xlfR+aAv/4/13slhGaamCfXeTYWI0=";
        "extern/dawn/third_party/spirv-tools/src" = chromium "external/github.com/KhronosGroup/SPIRV-Tools" "5b5a25231a3543559b4f2cb27fe725a08b76b5d0" "sha256-TTAPL6Hc39rLzzWe1g4FafXITfvmrSz+p9e6gouhF8M=";
        "extern/dawn/third_party/vulkan-headers/src" = chromium "external/github.com/KhronosGroup/Vulkan-Headers" "f9973cd97e6f3584707e7ef1c425e336f1b92a5b" "sha256-2nUIH32JxkR++1CVZqCu7E3BurAY8UjOf/B4JmJXxd0=";
        "extern/dawn/third_party/vulkan-utility-libraries/src" = chromium "external/github.com/KhronosGroup/Vulkan-Utility-Libraries" "6673ca41d73d36c3c838451e66dd30dd1ec46a97" "sha256-IZ/qURQ67yRqXVwYpiy7ePx2+pj1S0D5egLZUvQCEp8=";
      };

      package = pkgs:
        let
          inherit (pkgs) lib;
          # The build reads its dependencies through Git and checks their
          # commits, so each one is fetched as a repository.
          sources = lib.mapAttrs (_: pin: pkgs.fetchgit (pin // {
            leaveDotGit = true;
            fetchSubmodules = false;
          })) pins;
        in
        # Clang with GCC's C++ runtime, like the released Linux builds.
        pkgs.clangStdenv.mkDerivation {
          pname = "recharged";
          version = "1.1.7";
          src = self;

          nativeBuildInputs = toolsOf pkgs ++ [ pkgs.rustPlatform.cargoSetupHook ];
          buildInputs = libsOf pkgs;
          # The released builds are compiled without distribution hardening,
          # which the decompiled game code was never checked against.
          hardeningDisable = [ "all" ];
          dontUseCmakeConfigure = true;
          # The build refuses dependency checkouts with edited files.
          dontUpdateAutotoolsGnuConfigScripts = true;
          dontStrip = true;

          cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
            src = sources."extern/nod";
            hash = "sha256-AxjCefkC+EQf0WM7bKF7Hn7ToCBTROsowoffxIzLREE=";
          };
          cargoRoot = "extern/nod";

          # mapAttrsToList goes by name, so a repository precedes its nested ones.
          postUnpack = lib.concatStrings (lib.mapAttrsToList (path: source: ''
            mkdir -p $sourceRoot/${path}
            cp -r ${source}/. $sourceRoot/${path}
            chmod -R u+w $sourceRoot/${path}
            git -C $sourceRoot/${path} reset -q
          '') sources) + ''
            # The build reads the pins from the index and its version from HEAD.
            git -C $sourceRoot init -q
            git -C $sourceRoot add -A 2>/dev/null
            GIT_AUTHOR_DATE="${toString self.lastModified} +0000" GIT_COMMITTER_DATE="${toString self.lastModified} +0000" \
              git -C $sourceRoot -c user.name=nix -c user.email=nix@localhost commit -qm "${self.rev or self.dirtyRev or "unknown"}"
          '';

          configurePhase = ''
            runHook preConfigure
            # nod links its own zlib and zstd; cargoSetupHook asks for the system's.
            unset LIBZ_SYS_STATIC ZSTD_SYS_USE_PKG_CONFIG
            # The game checks its compilation date (__DATE__), which Nix sets to 1980.
            export SOURCE_DATE_EPOCH=${toString self.lastModified}
            # The scanner beside nixpkgs' clang does not know the C++ runtime's
            # headers; the one of clang-tools does.
            cmake --preset release -DBUILD_TESTING=OFF -DMSCHARGED_FORMAT_PREPARED_SOURCES=OFF \
              -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS=${pkgs.clang-tools}/bin/clang-scan-deps
            runHook postConfigure
          '';
          # Only the packaged targets, as in .github/workflows/build.yml.
          buildPhase = ''
            runHook preBuild
            cmake --build --preset release -j $NIX_BUILD_CORES --target mscharged \
              mscharged_original_frontend_module_us mscharged_original_frontend_module_eu \
              mscharged_original_frontend_module_jp mscharged_original_frontend_module_kr
            runHook postBuild
          '';
          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin $out/lib/recharged
            cp -r build/release/{recharged,recharged_game_*.so,assets} $out/lib/recharged
            # The program keeps its settings, saves and game folder beside
            # itself, so it runs from a writable copy of this package. SDL and
            # Dawn open the window system and Vulkan libraries at run time.
            cat > $out/bin/recharged <<EOF
            #!${pkgs.runtimeShell}
            dir="\''${XDG_DATA_HOME:-\$HOME/.local/share}/recharged"
            if [ "\$(cat "\$dir/.nix-store-path" 2>/dev/null)" != $out ]; then
              mkdir -p "\$dir"
              cp -rf --remove-destination $out/lib/recharged/. "\$dir"
              chmod -R u+w "\$dir/recharged" "\$dir"/recharged_game_*.so "\$dir/assets"
              echo $out > "\$dir/.nix-store-path"
            fi
            # Steam's Vulkan overlay layer crashes when the launcher hands
            # over to the game; Game Mode draws its overlay without it.
            export DISABLE_VK_LAYER_VALVE_steam_overlay_1=1
            export LD_LIBRARY_PATH=${lib.makeLibraryPath (libsOf pkgs)}\''${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}
            exec "\$dir/recharged" "\$@"
            EOF
            chmod +x $out/bin/recharged
            runHook postInstall
          '';

          meta.mainProgram = "recharged";
        };
    in {
      packages = perSystem (pkgs: { default = package pkgs; });

      devShells = perSystem (pkgs: {
        default = (pkgs.mkShell.override { stdenv = pkgs.clangStdenv; }) {
          packages = toolsOf pkgs ++ [ pkgs.clang-tools ];
          buildInputs = libsOf pkgs;
          hardeningDisable = [ "all" ];
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (libsOf pkgs);
        };
      });
    };
}
