s.boot;


(
~library = Array.new;
~folder = PathName.new(); //write in the parentheses the pathname of the folder with the stereo audio files

~folder.entries.do({
	arg path;
	~library = ~library.add(Buffer.read(s, path.fullPath));
});
)
(
SynthDef.new(\EpiTime, {
	arg amp=1, out=0, buf, start, end, rate=1, rlag=0, bal=0;
	var sig, ptr;
	rate = Lag.kr(rate, rlag);
	ptr = Phasor.ar(0, BufRateScale.kr(buf)*rate, start, end);
	sig = BufRd.ar(2, buf, ptr);
	sig = Balance2.ar(sig[0], sig[1], bal);
	sig = sig * amp;
	Out.ar(out, sig*2);
}).add;


Window.closeAll;
s.freeAll;
w = Window("EpiTime", Rect(500,500,600,250))
.background_(Color(0.3,0.65,0.95))
.front
.alwaysOnTop_(true);

//1os ixos
//Balance
~pan = EZKnob(w, Rect(350,85,75,30), "Balance ", \bipolar,
	{|ez| x.set( "bal", ez.value )},labelHeight:9,layout:\line2);
//Speed
~rate_slider = Slider(w, Rect(50,20,300,30))
.background_(Color.magenta)
.value_(0.5)
.action_({
	arg obj;
	var speed;
	speed = obj.value.linexp(0,1,1/50,50).postln;
	if(
		x.isPlaying,
		{x.set(\rate, speed)}
	);

});
//Reverce
~reverse = Button(w, Rect(465,20,60,30))
.states_([
	["Reverse", Color.black, Color.gray(0.8)],
	["Reverse", Color.white, Color.magenta]
])
.font_(Font("Monaco", 15))
.action_({
	arg obj;
	if(
		obj.value == 0,

		{
			~rate_slider = Slider(w, Rect(50,20,300,30))
.background_(Color.magenta)
.value_(~rate_slider.value)
.action_({
	arg obj;
	var speed;
	speed = obj.value.linexp(0,1,1/50,50).postln;
	if(
		x.isPlaying,
		{x.set(\rate, speed)}
	);
			});
		},
		{~rate_slider = Slider(w, Rect(50,20,300,30))
.background_(Color.magenta)
.value_(~rate_slider.value)
.action_({
	arg obj;
	var speed;
				speed = obj.value.linexp(0,1,1/50,50)*(-1).postln;
	if(
		x.isPlaying,
		{x.set(\rate, speed)}
	);
			});}
	);
});
//Loop
a = RangeSlider(w, Rect(50, 60, 300, 20))
	.background_(Color(1,1,1))
    .lo_(0)
    .hi_(1)
    .action_({ |slider|
        ~slider_start1.valueAction_(slider.lo); // this will trigger the action of slider_start & slider_end (and set it's value)
        ~slider_end1.valueAction_(slider.hi);
    });
~slider_start1 = Slider(q, Rect(50,50,300,15))
.background_(Color.blue)
.action_({
	arg obj;
	var start1;

	start1 = obj.value.linexp(0,1,2000,~library[0].numFrames-1).postln;
	if(
		x.isPlaying,
		{x.set(\start, start1)}
	);

});
~slider_end1 = Slider(q, Rect(50,65,300,15))
.background_(Color.blue)
.value_(~library[0].numFrames)
.action_({
	arg obj;
	var end1;

	end1 = obj.value.linexp(0,1,2001,~library[0].numFrames).postln;
	if(
		x.isPlaying,
		{x.set(\end, end1)}
	);

});

//Volume
~vol = Knob(w, Rect(360,20,30,30))
.action_({
	arg obj;
	var vol;
	vol = obj.value.linexp(0,1,100000/1,1).reciprocal;
	if(
		x.isPlaying,
		{x.set(\amp, vol)}
	);
});
//Speed Latency
~lag_numbox = NumberBox(w, Rect(365, 60, 20, 20))
	.clipLo_(0)
	.clipHi_(50)
    .action_({
	arg obj;
	var num;
	num = obj.value;
	if(
		x.isPlaying,
		{x.set(\rlag, num)}
	);
			});
//Play/Stop
~button = Button(w, Rect(530,20,50,30))
.states_([
	["Play", Color.black, Color.gray(0.8)],
	["Stop", Color.white, Color.magenta]
])
.font_(Font("Monaco", 15))
.action_({
	arg obj;
	if(
		obj.value == 1,

		{
			x = Synth.new(
				\EpiTime,
				[
					\buf, ~library[0].bufnum, \amp, ~vol.value.linexp(0,1,100000/1,1).reciprocal, \rate, ~rate_slider.value.linexp(0,1,1/50,50), \start, 	~slider_start1.value.linexp(0,1,2000,~library[0].numFrames-1), \end, ~slider_end1.value.linexp(0,1,2001,~library[0].numFrames), \rlag, ~lag_numbox.value, \bal, ~pan.value
				]
			).register;
		},
		{x.free}
	);
});

// names
~speed_text = StaticText(w, Rect(10, 20, 30, 20))
.string_("Speed");
~loop_text = StaticText(w, Rect(10, 60, 25, 20))
.string_("Loop");
~vol_text = StaticText(w, Rect(400, 20, 40, 20))
.string_("Volume");
~vol_0_text = StaticText(w, Rect(390, 36, 20, 20))
.string_("-0");
~vol_6_text = StaticText(w, Rect(373, 42, 20, 20))
.string_("+6");
~lag_text = StaticText(w, Rect(400, 55, 37, 30))
.string_("Speed Latency");

//2os ixos
//Balance
~pan2 = EZKnob(w, Rect(350,205,75,30), "Balance ", \bipolar,
	{|ez| y.set( "bal", ez.value )},labelHeight:9,layout:\line2);
//Speed
~rate_slider2 = Slider(w, Rect(50,140,300,30))
.background_(Color.magenta)
.value_(0.5)
.action_({
	arg obj;
	var speed;
	speed = obj.value.linexp(0,1,1/50,50).postln;
	if(
		y.isPlaying,
		{y.set(\rate, speed)}
	);

});
//Reverse
~reverse2 = Button(w, Rect(465,140,60,30))
.states_([
	["Reverse", Color.black, Color.gray(0.8)],
	["Reverse", Color.white, Color.magenta]
])
.font_(Font("Monaco", 15))
.action_({
	arg obj;
	if(
		obj.value == 0,

		{
			~rate_slider2
		},
		{~rate_slider2 * (-1)}
	);
});
//Loop
b = RangeSlider(w, Rect(50, 180, 300, 20))
	.background_(Color(1,1,1))
    .lo_(0)
    .hi_(1)
    .action_({ |slider|
        ~slider_start2.valueAction_(slider.lo); // this will trigger the action of slider_start & slider_end (and set it's value)
        ~slider_end2.valueAction_(slider.hi);
    });
~slider_start2 = Slider(q, Rect(50,50,300,15))
.background_(Color.blue)
.action_({
	arg obj;
	var start1;

	start1 = obj.value.linexp(0,1,2000,~library[1].numFrames-1).postln;
	if(
		y.isPlaying,
		{y.set(\start, start1)}
	);

});
~slider_end2 = Slider(q, Rect(50,65,300,15))
.background_(Color.blue)
.value_(~library[1].numFrames)
.action_({
	arg obj;
	var end1;

	end1 = obj.value.linexp(0,1,2001,~library[1].numFrames).postln;
	if(
		y.isPlaying,
		{y.set(\end, end1)}
	);

});

//Volume
~vol2 = Knob(w, Rect(360,142,30,30))
.action_({
	arg obj;
	var vol;
	vol = obj.value.linexp(0,1,100000/1,1).reciprocal;
	if(
		y.isPlaying,
		{y.set(\amp, vol)}
	);
});
//Speed Latency
~lag_numbox2 = NumberBox(w, Rect(365, 180, 20, 20))
	.clipLo_(0)
	.clipHi_(50)
    .action_({
	arg obj;
	var num;
	num = obj.value;
	if(
		y.isPlaying,
		{y.set(\rlag, num)}
	);
			});
//Play/Stop
~button2 = Button(w, Rect(530,140,50,30))
.states_([
	["Play", Color.black, Color.gray(0.8)],
	["Stop", Color.white, Color.magenta]
])
.font_(Font("Monaco", 15))
.action_({
	arg obj;
	if(
		obj.value == 1,

		{
			y = Synth.new(
				\EpiTime,
				[
					\buf, ~library[1].bufnum, \amp, ~vol2.value.linexp(0,1,100000/1,1).reciprocal, \rate, ~rate_slider2.value.linexp(0,1,1/50,50), \start, 	~slider_start2.value.linexp(0,1,2000,~library[1].numFrames-1), \end, ~slider_end2.value.linexp(0,1,2001,~library[1].numFrames), \rlag, ~lag_numbox2.value, \bal, ~pan2.value
				]
			).register;
		},
		{y.free}
	);
});

// names
~speed_text2 = StaticText(w, Rect(10, 140, 30, 20))
.string_("Speed");
~loop_text2 = StaticText(w, Rect(10, 180, 25, 20))
.string_("Loop");
~vol_text2 = StaticText(w, Rect(400, 150, 40, 20))
.string_("Volume");
~vol_0_text2 = StaticText(w, Rect(390, 156, 20, 20))
.string_("-0");
~vol_6_text2 = StaticText(w, Rect(373, 162, 20, 20))
.string_("+6");
~lag_text2 = StaticText(w, Rect(400, 175, 37, 30))
.string_("Speed Latency");

)

s.freeAll
