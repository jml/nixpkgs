{ stdenv, fetchurl, SDL2, mesa_noglu, libpng, libjpeg, SDL2_ttf, libvorbis, gettext
, physfs }:

stdenv.mkDerivation rec {
  name = "neverball-1.6.0";
  src = fetchurl {
    url = "http://neverball.org/${name}.tar.gz";
    sha256 = "184gm36c6p6vaa6gwrfzmfh86klhnb03pl40ahsjsvprlk667zkk";
  };

  buildInputs = [ libpng SDL2 mesa_noglu libjpeg SDL2_ttf libvorbis gettext physfs ];

  dontPatchElf = true;

  patchPhase = ''
    sed -i -e 's@\./data@'$out/data@ share/base_config.h Makefile
    sed -i -e 's@\./locale@'$out/locale@ share/base_config.h Makefile
    sed -i -e 's@-lvorbisfile@-lvorbisfile -lX11 -lgcc_s@' Makefile
  '';

  # The map generation code requires a writable HOME
  preConfigure = "export HOME=$TMPDIR";

  installPhase = ''
    mkdir -p $out/bin $out
    cp -R data locale $out
    cp neverball $out/bin
    cp neverputt $out/bin
    cp mapc $out/bin
  '';

  meta = {
    homepage = http://neverball.org/;
    description = "Tilt the floor to roll a ball";
    license = "GPL";
    maintainers = with stdenv.lib.maintainers; [viric];
    platforms = with stdenv.lib.platforms; linux;
  };
}
