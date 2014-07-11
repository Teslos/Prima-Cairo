use strict;
use warnings;
use DateTime;
use Prima qw(Application Cairo);
use constant PI => 3.141592;

my($width, $height);

 sub time_now {
	my $dt = DateTime->now(time_zone=>'local');
	
	my $hours = $dt->hour;
	my $minutes = $dt->minute;
	my $secs = $dt->second;
	
	my $second_arc = (2 * PI / 60) * $secs;
	my $minute_arc = (2 * PI / 60) * $minutes;
	if ($hours > 12) {
		$hours = $hours - 12;
	}
	my $hour_arc = (2 * PI / 12) * $hours + $minute_arc / 12;
	return ($hour_arc, $minute_arc, $second_arc);
}

 sub min($$) { return ($_[0] < $_[1] ? $_[0] : $_[1]);  }

 sub draw_cursor {
	my ($cr, $color, $width_line, $length, $position) = @_;
	my $mid = min($width,$height);
	$cr->set_source_rgba($color->[0],$color->[1], $color->[2], $color->[3]);
    	$cr->set_line_width($width_line);
	$cr->set_line_cap('round');
    	$cr->move_to($width/2, $height/2);
    	$cr->line_to($width/2 + $length * cos($position - PI/2),
    	$height/2 + $length * sin($position - PI/2));
    	$cr->stroke;
}

 sub draw_arc {
	my($cr, $color, $w, $h, $radius) = @_;
	$cr->set_source_rgb( $color->[0], $color->[1], $color->[2] );
	$cr->arc($w, $h, $radius, 0, 2 * PI);
	$cr->fill;
	$cr->stroke;
}
	
 sub create_image {
	my ($cr) = @_;
   
	my($hour_arc, $minute_arc, $second_arc) = time_now();
	my $mid = min($width,$height);
	
	# make a clock background 
	my @color_back = (0,0,0);
	draw_arc($cr, \@color_back, $width/2, $height/2, $mid/2 - 8 );
	
	@color_back = (0.5, 0.5, 0.5);
	draw_arc($cr, \@color_back, $width/2, $height/2, $mid/2 - 20 );
	
	# pointer hour
	my @color = (0.4, .78, 0.0, 0.5);  
	draw_cursor($cr, \@color, ($mid/2 - 20)/6, ($mid/2 - 20) * 0.6, $hour_arc);
   
	#pointer minute
	draw_cursor($cr, \@color, ($mid/2 - 20)/6 * .53, ($mid/2 - 20) * 0.8, $minute_arc);

	#pointer second
	my @color_sec = (1.0, 0.0, 0.0, 1.0);
	draw_cursor($cr, \@color_sec, ($mid/2 - 20)/6 * .2, ($mid/2 - 20), $second_arc);
	
	# center arc
	@color_back = (1, 1, 1);
	draw_arc($cr, \@color_back, $width/2, $height/2, ($mid/2 - 20)/12 );
	
	$cr->set_source_rgb(0, 0, 0);
	$cr->select_font_face("Sans-serif", 'normal', 'bold');
	$cr->set_font_size(10.0);
	$cr->move_to(10, $height - 10);
	$cr->show_text("teslos");
	$cr->fill;
	$cr->show_page;
   
}

my $w = Prima::MainWindow->new(
	text => 'Analog clock',
	size => [300,300],
	onPaint => sub {
		#on paint event
	},
	onCreate => sub {
		my $timer = $_[0]->insert( Timer => timeout => 1000, name => 'Timer',
		onTick => sub {
			my $canvas = $_[0]->owner;
			$canvas->clear;
			my @size = $canvas->size;
			($width, $height) = @size;
			print "Width: $width, height: $height\n";
			my $cr = $canvas->cairo_context( transform => 0 );
			my $matrix = Cairo::Matrix->init_identity;
			$cr->scale($size[0]/300, $size[1]/300);
			$cr->transform($matrix);
			create_image($cr); 
		}
		);
		$timer->start;
	}
);
run Prima;
		 

