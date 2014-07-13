use Prima::Cairo::Drawable;
use Prima::PS::Drawable;

use strict;
use warnings;
use constant M_PI => 3.14159265359;

my $width = 595;
my $height = 842;
my $a = Prima::Image->new( width => $width, height => $height );
$a->begin_paint;
$a->clear;
$a->lines([0,0,10,10,0,10,20,20]);
$a->end_paint;
$a->type(im::BW);
my $a1 = Prima::Cairo::to_cairo_surface($a, 'a1');
$a1->write_to_png('lines.png');

my $x = Prima::Cairo::Drawable->create( pageSize => [$width, $height], resolution => [72,72] );
my $surface = Cairo::ImageSurface->create( 'argb32', $width, $height);
$x->surface($surface);
die "error: $@" unless $x->begin_paint;

$x->lineWidth(1.0);
$x->arc(0,0, 100, 100, 0, M_PI);

$x->lineWidth(5.0);
$x->ellipse(0,0, 300, 300);

$x->lineWidth(2.0);
$x->color(cl::Green);
$x->rectangle(10,10,160,160);

#$x->fillPattern(fp::Solid);
$x->fill_ellipse(60,60, 100,100);

$x->lineEnd(le::Flat);
$x->color(cl::Blue);
$x->lineWidth(1.0);
$x->lines([0,0,10,10,0,10,20,20]);
$x->ellipse(10,10,20,20);
$x->chord(20,20,30,30, 0.,2*M_PI/3);

my @a = (20,20,40,0,0,70);
$x->polyline(\@a);

#test line patterns
my @lpPatterns = (lp::Null, lp::Solid, lp::Dash, lp::LongDash, lp::ShortDash, 
 lp::Dot, lp::DotDot, lp::DashDot, lp::DashDotDot);
my $offset = 300.;
foreach my $lp (@lpPatterns) {
        $x->color(cl::Black);
	#print "Line pattern: $lp\n";
	$x->linePattern($lp);
	$x->line(0., $offset, 200, $offset);
	$offset += 20;
} 

# test fill patterns
my @fpPatterns = (fp::Empty, fp::Solid, fp::Line, fp::LtSlash, fp::Slash,
  fp::BkSlash, fp::LtBkSlash, fp::Hatch, fp::XHatch, fp::Interleave, fp::WideDot,
  fp::CloseDot, fp::SimpleDots, fp::Borland, fp::Parquet);
$offset = 300;
foreach my $fp (@fpPatterns) {
	$x->color(cl::Black);
	$x->fillPattern($fp);
	$x->bar(300., $offset, 500, $offset+20.);
	$offset += 30;
}

$x->end_paint;
$surface->write_to_png('test.png');

