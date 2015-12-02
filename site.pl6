use v6;

use Bailador;
use Text::VimColour;
use MIME::Types;

grammar CSS {
    token TOP { <-[.]>+ [<pair> \n+]* <-[.]>+ }
    token ws { \h* }
    rule  pair  { \.<class=.class> '{' <rules=.rules> '}' }
    token class { \w+ }
    token rules { <-[}]>+ }
}

class CSSActions {
    method class     ($/) { $/.make: ~$/                            }
    method rules     ($/) { $/.make: ~$/                            }
    method pair      ($/) { $/.make: $<class>.made => $<rules>.made }
    method TOP       ($/) { $/.make: $<pair>».made                  }
}

Bailador::import;
my $MIME = MIME::Types.new("/etc/mime.types");

get '/' => sub {
    template 'index.tt';
};

post '/' => sub {
    my $code = request.params<code>;

    my $v = Text::VimColour.new( lang => 'perl6', code => $code, );
    my $html = $v.html;
    my $css  = $v.css;

    $html ~~ s/"id='vimCodeElement'"/style="white-space: pre-wrap; font-family: monospace; color: #000000; background-color: #ffffff"/;

    my $res = CSS.parse($css, :actions(CSSActions)).made;
    for @$res -> $p {
        my ( $k, $v ) = ( $p.key, $p.value );
        $v ~~ s:g/'text-decoration: underline;'//;
        $html = $html.subst(qq{class="$k"}, qq{style="$v"}, :g);
    }

    $html ~~ s:g/'^M'//;

    template 'index.tt',{ code => $html };
};

get /^ '/' ('public/' [scss|js] '/'  \w+  '.min'?)  \.(\w ** 2..3)$/
=> sub ($file, $ext) {
    content_type $MIME.type($ext) // "application/octet-stream";
    return slurp "$file.$ext" if "$file.$ext".IO.f;
    status 404; return "File not found";
};

baile;
