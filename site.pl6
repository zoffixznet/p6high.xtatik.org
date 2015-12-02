use v6;

use Bailador;
Bailador::import;
use MIME::Types;
my $MIME = MIME::Types.new("/etc/mime.types");

get /^ '/' ('public/' [scss|js] '/'  \w+  '.min'?)  \.(\w**3)$/
=> sub ($file, $ext) {
    content_type $MIME.type($ext) // "application/octet-stream";
    return slurp "$file.$ext" if "$file.$ext".IO.f;
    status 404; return "File not found";
}

baile;
