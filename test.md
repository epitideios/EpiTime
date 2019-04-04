# Εργασία
 ## Αθανάσιος Επιτήδειος

### Εισαγωγή
Στην εργασία αυτή παρουσιάζεται η ανάπτυξη και η λειτουργία του EpiTime, το οποίο είναι ένα loop player δυο καναλιών με δυνατότητα αλλαγής του βρόχου (loop), του ρυθμού αναπαραγωγής (rate) και άλλων παραμέτρων. Αναπτύχθηκε στη γλώσσα προγραμματισμού SuperCollider και εμφανίζεται με γραφικό περιβάλλον χρήστη (GUI). Στο User Interface (διεπαφή χρήστη) υπάρχουν οι μεταβαλλόμενες παράμετροι υπό τη μορφή, sliders, knobs και buttons, με τους οποίους ο χρήστης μπορεί να επεξεργάζεται σε πραγματικό χρόνο τα αναπαραγόμενα ηχητικά δείγματα.


### Περιγραφή EpiTime
Στο γραφικό περιβάλλον, ο χρήστης έρχεται σε επαφή με επτά διαφορετικούς παραμέτρους για κάθε κανάλι με τους οποίους καλείται να επεξεργαστεί τους ήχους που έχει επιλέξει. Αναφορικά, oι παράμετροι αυτοί είναι :
* Play/Stop
* Volume
* Balance
* Speed
* Speed Latency
* Reverse
* Loop

#### Κώδικας
Στον κώδικα του EpiTime γίνεται χρήση της κλάσης buffer για τη φόρτωση μιας συστοιχίας αρχείων ήχου. 
```
~library = Array.new;
~folder = PathName.new();

~folder.entries.do({
	arg path;
	~library = ~library.add(Buffer.read(s, path.fullPath));
```	
Στη συνέχεια γίνεται χρήση της κλάσης SynthDef.
```
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
```
Για τη δημιουργία της λούπας χρησιμοποιείται το `BufRd.ar` και το `Phasor.ar` με τις μεταβλητές `start` και `end` να ελέγχουν τη διάρκεια της λούπας ανάλογα με τα `numframes` του ηχητικού δείγματος. Επίσης, γίνεται χρήση του `BufRateScale.kr` ώστε η αναπαραγωγή ήχων με διαφορετικό ρυθμό δειγματοληψίας (samplerate) από αυτό του διακομιστή (server), να είναι δυνατή χωρίς την αλλαγή της ταχύτητας αναπαραγωγής του δείγματος. Το `Lag.kr` χρησιμοποιεί το `rate` ως είσοδο και το argument `rlag` ως χρόνο καθυστέρησης. Με αυτό τον τρόπο επιτυγχάνεται η ταχύτητα αλλαγής του `rate` όταν αυτό αλλάξει τιμή.

Εν συνεχεία περιγράφεται η λειτουργία κάθε παραμέτρου.

#### GUI

##### Play/Stop
Βρίσκεται υπό τη μορφή κουμπιού (button) και η χρήση του είναι η ενεργοποίηση και η απενεργοποίηση της αναπαραγωγής του ήχου.
````
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
````

##### Volume
Είναι ένα ποτενσιόμετρο (knob) το οποίο ελέγχει την ένταση του ήχου, με δυνατότητα αύξησης κέρδους (gain) έως +6db.
````
~vol = Knob(w, Rect(360,20,30,30))
.action_({
	arg obj;
	var vol;
	vol = obj.value.linexp(0,1,100000/1,1).reciprocal;
	if(
		x.isPlaying,
		{x.set(\amp, vol)}
	);
````

##### Balance
Το Balance γνωστό και ως Pan pot ελέγχει την ισορροπία της στερεοφωνικής εικόνας του ήχου με τη χρήση ενός ποτενσιόμετρου.
````
~pan = EZKnob(w, Rect(350,85,75,30), "Balance ", \bipolar,
	{|ez| x.set( "bal", ez.value )},labelHeight:9,layout:\line2);
````

##### Speed
Με τη χρήση του ολισθητή (slider) Speed επιτυγχάνεται η αλλαγή του ρυθμού αναπαραγωγής του ήχου.
````
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

````
##### Speed Latency
Το Speed Latency καθορίζει το πόσο γρήγορα θα αλλάξει η τιμή του speed.
````
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
````

##### Reverse
Με το κουμπί reverse επιτυγχάνεται η αντίστροφη αναπαραγωγή του ηχητικού δείγματος.
````
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
````

##### Loop
Τέλος με το ολισθητή εύρους (range slider) Loop γίνεται έλεγχος της λούπας του ήχου.
````
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
````
