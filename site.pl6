use v6;

use Bailador;
use Text::VimColour;
use MIME::Types;

Bailador::import;
my $MIME = MIME::Types.new("/etc/mime.types");

get '/' => sub {
    template 'index.tt';
};

post '/' => sub {
    my $code = request.params<code>;

    $code = Text::VimColour.new( lang => 'perl6', code => $code, )
        .html-full-page;

    say "woo $code";
    template 'index.tt',{ code => $code };
};

get /^ '/' ('public/' [scss|js] '/'  \w+  '.min'?)  \.(\w ** 2..3)$/
=> sub ($file, $ext) {
    content_type $MIME.type($ext) // "application/octet-stream";
    return slurp "$file.$ext" if "$file.$ext".IO.f;
    status 404; return "File not found";
};

baile;
