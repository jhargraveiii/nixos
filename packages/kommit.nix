{ cmake
, extra-cmake-modules
, fetchFromGitLab
, lib
, libgit2
, libsForQt5
, nix-update-script
, openssl
, pcre
, pkg-config
, stdenv
, zlib
}:

stdenv.mkDerivation rec {
  pname = "kommit";
  version = "1.4.0";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sdk";
    repo = "kommit";
    rev = "v${version}";
    hash = "sha256-H/GPgS63fNI1t6gIavTpoBX+yCkCa1sU50eKluHv5Ao=";
  };

  nativeBuildInputs = with libsForQt5; [
    cmake
    kdoctools
    pkg-config
    qt5.wrapQtAppsHook
  ];

  buildInputs = with libsForQt5; [
    dolphin.dev
    extra-cmake-modules
    kconfigwidgets
    kcoreaddons
    kcrash
    kdbusaddons
    ki18n
    kio
    ktexteditor
    ktextwidgets
    libgit2
    openssl
    pcre
    zlib
  ];

  # todo: uncomment this when `nix-update` is version higher than 1.1.0
  #passthru.updateScript = nix-update-script {
  #  extraArgs = [ "--version-regex" "^(v[0-9.]+)$" ];
  #};

  meta = with lib; {
    description = "Graphical Git Client";
    homepage = "https://invent.kde.org/sdk/kommit";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
