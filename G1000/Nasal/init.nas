screen1 = {};
var GDU104XINIT = {
    new: func(screenID,mode)
    {
        var m = { parents:[  GDU104XINIT   ] };
        m.canvas = canvas.new({
                "name": "screen"~screenID,
                "size": [1024, 768],
                "view": [1024, 768],
                "mipmapping": 1
        });
        m.canvas.addPlacement({"node": "Screen", "parent":"screen"~screenID});
        m.canvas.setColorBackground(1,1,1);
        m.croot = m.canvas.createGroup();

        m.canvas.setColorBackground(0.12,0.20,0.16);
        m.top = m.canvas.createGroup();
        if(mode == "PFD"){
            m.PFD = PFD.new(m.croot);
        }elsif(mode == "MFD"){
        };
        var font_mapper = func(family, weight)
		{
			if( family == "Liberation Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
            #elsif( family == "Liberation Sans Narrow" and weight == "normal" )
    		#	return "LiberationFonts/LiberationSansNarrow-Regular.ttf";
			elsif( family == "Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
			elsif( family == "BoeingCDULarge" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";

		};
        canvas.parsesvg(m.top, "Aircraft/Instruments-3d/Farmin/G1000/Pages/top.svg", {'font-mapper': font_mapper});

	if (mode == "PFD") {
		m.top.getElementById("text5363").setText("");
		m.top.getElementById("softKeyText01").setText("");
		m.top.getElementById("softKeyText02").setText("");
		m.top.getElementById("softKeyText03").setText("");
		m.top.getElementById("softKeyText04").setText("");
		m.top.getElementById("softKeyText05").setText("CDI");
		m.top.getElementById("softKeyText06").setText("");
		m.top.getElementById("softKeyText07").setText("");
		m.top.getElementById("softKeyText08").setText("");
		m.top.getElementById("softKeyText09").setText("");
		m.top.getElementById("text5109").setText("");
		m.top.getElementById("text5129").setText("");
	}

	m.top.getElementById("rect3875-5").hide();     #NAV1 active cursor
	m.top.getElementById("rect3875-6-6").hide();   #NAV2 active cursor
	m.top.getElementById("rect3875-3").hide();     #COM1 active cursor
	m.top.getElementById("rect3875-6-9").hide();   #COM2 active cursor
	setlistener("/instrumentation/nav[0]/serviceable",
	    func(){ m.updateNAV1() }, 1, 0);
	setlistener("/instrumentation/nav[0]/frequencies/selected-mhz",
	    func(){ m.updateNAV1() }, 0, 0);
	setlistener("/instrumentation/nav[0]/frequencies/standby-mhz",
	    func(){ m.updateNAV1() }, 0, 0);
	setlistener("/instrumentation/nav[1]/serviceable",
	    func(){ m.updateNAV2() }, 1, 0);
	setlistener("/instrumentation/nav[1]/frequencies/selected-mhz",
	    func(){ m.updateNAV2() }, 0, 0);
	setlistener("/instrumentation/nav[1]/frequencies/standby-mhz",
	    func(){ m.updateNAV2() }, 0, 0);
	setlistener("/instrumentation/comm[0]/serviceable",
	    func(){ m.updateCOM1() }, 1, 0);
	setlistener("/instrumentation/comm[0]/frequencies/selected-mhz",
	    func(){ m.updateCOM1() }, 0, 0);
	setlistener("/instrumentation/comm[0]/frequencies/standby-mhz",
	    func(){ m.updateCOM1() }, 0, 0);
	setlistener("/instrumentation/comm[1]/serviceable",
	    func(){ m.updateCOM2() }, 1, 0);
	setlistener("/instrumentation/comm[1]/frequencies/selected-mhz",
	    func(){ m.updateCOM2() }, 0, 0);
	setlistener("/instrumentation/comm[1]/frequencies/standby-mhz",
	    func(){ m.updateCOM2() }, 0, 0);
        return m;
    },
    updateNAV1: func() {
	me.top.getElementById("rect3875-6").hide();
	me.top.getElementById("path4003-0").hide();
	selected = getprop("instrumentation/nav[0]/frequencies/selected-mhz");
	standby = getprop("instrumentation/nav[0]/frequencies/standby-mhz");
	if (getprop("instrumentation/nav[0]/serviceable") == 1 and selected != nil and standby != nil) {
	    selected = sprintf("%5.2f", selected);
	    standby = sprintf("%5.2f", standby);
	    me.top.getElementById("g4375").hide();
	    me.top.getElementById("rect3875").show();
	    me.top.getElementById("path4003").show();
	} else {
	    selected = "---.--";
	    standby = "---.--";
	    me.top.getElementById("g4375").show();
	    me.top.getElementById("rect3875").hide();
	    me.top.getElementById("path4003").hide();
	}
	me.top.getElementById("text4109").setText(selected);
	me.top.getElementById("text4109-7").setText(standby);
    },
    updateNAV2: func() {
	me.top.getElementById("rect3875").hide();
	me.top.getElementById("path4003").hide();
	selected = getprop("instrumentation/nav[1]/frequencies/selected-mhz");
	standby = getprop("instrumentation/nav[1]/frequencies/standby-mhz");
	if (getprop("instrumentation/nav[1]/serviceable") == 1 and selected != nil and standby != nil) {
	    selected = sprintf("%5.2f", selected);
	    standby = sprintf("%5.2f", standby);
	    me.top.getElementById("g4392").hide();
	    me.top.getElementById("rect3875-6").show();
	    me.top.getElementById("path4003-0").show();
	} else {
	    selected = "---.--";
	    standby = "---.--";
	    me.top.getElementById("g4392").show();
	    me.top.getElementById("rect3875-6");
	    me.top.getElementById("path4003-0").hide();
	}
	me.top.getElementById("text4109-5").setText(selected);
	me.top.getElementById("text4109-5-2").setText(standby)
    },
    updateCOM1: func() {
	me.top.getElementById("rect3875-6-6-3").hide();
	me.top.getElementById("path4003-0-4").hide();
	selected = getprop("instrumentation/comm[0]/frequencies/selected-mhz");
	standby = getprop("instrumentation/comm[0]/frequencies/standby-mhz");
	if (getprop("instrumentation/comm[0]/serviceable") == 1 and selected != nil and standby != nil) {
	    selected = sprintf("%6.3f", selected);
	    standby = sprintf("%6.3f", standby);
	    me.top.getElementById("g4375-3").hide();
	    me.top.getElementById("rect3875-5-2").show();
	    me.top.getElementById("path4003-6").show();
	} else {
	    selected = "---.--";
	    standby = "---.--";
	    me.top.getElementById("g4375-3").show();
	    me.top.getElementById("rect3875-5-2").hide();
	    me.top.getElementById("path4003-6").hide();
	}
	me.top.getElementById("text4109-7-3").setText(selected);
	me.top.getElementById("text4109-1").setText(standby)
    },
    updateCOM2: func() {
	me.top.getElementById("rect3875-5-2").hide();
	me.top.getElementById("path4003-6").hide();
	selected = getprop("instrumentation/comm[1]/frequencies/selected-mhz");
	standby = getprop("instrumentation/comm[1]/frequencies/standby-mhz");
	if (getprop("instrumentation/comm[1]/serviceable") == 1 and selected != nil and standby != nil) {
	    selected = sprintf("%6.3f", selected);
	    standby = sprintf("%6.3f", standby);
	    me.top.getElementById("g4427").hide();
	    me.top.getElementById("rect3875-6-6-3").show();
	    me.top.getElementById("path4003-0-4").show();
	} else {
	    selected = "---.--";
	    standby = "---.--";
	    me.top.getElementById("g4427").show();
	    me.top.getElementById("rect3875-6-6-3").hide();
	    me.top.getElementById("path4003-0-4").hide();
	}
	me.top.getElementById("text4109-5-2-1").setText(selected);
	me.top.getElementById("text4109-5-9").setText(standby)
    },

};

var updater = func(){
    ILS = getprop("instrumentation/nav/gs-needle-deflection-norm")  or 0.00;
    screen1.PFD.updateAi();
    screen1.PFD.updateSpeed();
    screen1.PFD.UpdateHeading();
    screen1.PFD.updateAlt();
    screen1.PFD.updateSlipSkid();
    screen1.PFD.updateVSI();
    screen1.PFD.updateILS(ILS);
    settimer(func updater(), 0.05);
};

var updaterSlow = func()
{
    if(getprop("instrumentation/marker-beacon/outer"))
    {
        screen1.PFD.updateMarkers(1);
    }
    elsif(getprop("instrumentation/marker-beacon/middle"))
    {
        screen1.PFD.updateMarkers(2);
    }
    elsif(getprop("instrumentation/marker-beacon/inner"))
    {
        screen1.PFD.updateMarkers(3);
    }
    else
    {
        screen1.PFD.updateMarkers(0);
    }
    settimer(func updaterSlow(), 0.5);
}

setlistener("/nasal/canvas/loaded", func{
    screen1 = GDU104XINIT.new(1,'PFD');
    screen2 = GDU104XINIT.new(2,'MFD');
    updater();
    thread.newthread(updaterSlow);
}, 1, 0);
