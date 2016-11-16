# vim: tabstop=4 expandtab
screen1 = {};

mapsvg = func(tgt, svg, keylist)
    foreach (var key; keylist) {
        var elem = svg.getElementById(key);
        if (elem == nil)
            print("Element not found:", key);
        else {
            tgt[key] = nil;
            tgt[key] = elem;
        }
    };

var serviceableListener = func(showtrue, showfalse)
    func(node) {
        foreach (var key; showtrue)
            key.setVisible(node.getValue() == 1);
        foreach (var key; showfalse)
            key.setVisible(node.getValue() == 0);
    };

var textListener = func(tgt, format)
    func(node) {
        var text = node.getValue();
        if (format != nil)
            text = format(text);
        tgt.setText(text);
    };

var GDU104XINIT = {
    new: func(screenID,mode)
    {
        var m = { parents:[  GDU104XINIT   ] };
        m.canvas = canvas.new({
                "name": "FarminScreen"~screenID,
                "size": [1024, 768],
                "view": [1024, 768],
                "mipmapping": 1
        });
        m.canvas.addPlacement({"node": "Screen", "parent":"FarminScreen"~screenID});
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

        foreach(var key; ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
            "A", "B"]) m.top.getElementById("softKeyText"~key).setText("");
        foreach(var key; ["NAV1", "NAV2", "COM1", "COM2"])
            m.top.getElementById(key~"CURSOR2").hide();

        if (mode == "PFD") {
            m.top.getElementById("softKeyText5").setText("CDI");
            m.top.getElementById("softKeyText6").setText("DME");
            m.top.getElementById("softKeyText7").setText("ADF");
        };

        mapsvg(m, m.top, [
            "NAV1FREQ", "NAV1FAIL", "NAV1STANDBY", "NAV1SELECTED", "NAV1IDENT",
            "NAV2FREQ", "NAV2FAIL", "NAV2STANDBY", "NAV2SELECTED", "NAV2IDENT",
            "NAV1CURSOR", "NAV1SWAP", "NAV2CURSOR", "NAV2SWAP",
            "COM1FREQ", "COM1FAIL", "COM1STANDBY", "COM1SELECTED",
            "COM2FREQ", "COM2FAIL", "COM2STANDBY", "COM2SELECTED",
            "COM1CURSOR", "COM1SWAP", "COM2CURSOR", "COM2SWAP",
            "OATVAL", "LCLVAL", "XPDRVAL", "XPDRMODE"]);

        var fmtnav = func(f) sprintf("%6.2f", f);
        var fmtident = func(s) sprintf("%4s", s);
        setlistener("instrumentation/nav[0]/serviceable",
            serviceableListener([m.NAV1FREQ,], [m.NAV1FAIL,]), 1, 0);
	    setlistener("instrumentation/nav[0]/frequencies/standby-mhz",
	        textListener(m.NAV1STANDBY, fmtnav), 1, 0);
	    setlistener("instrumentation/nav[0]/frequencies/selected-mhz",
	        textListener(m.NAV1SELECTED, fmtnav), 1, 0);
	    setlistener("instrumentation/nav[0]/nav-id",
	        textListener(m.NAV1IDENT, fmtident), 1, 0);
	    setlistener("instrumentation/nav[0]/in-range",
	        serviceableListener([m.NAV1IDENT,], []), 1, 0);
        setlistener("instrumentation/FarminTemp/cdi-display", func(node)
            if (node.getValue() == "nav1") {
                m.NAV1SELECTED.setColor(0., 1., 0.);
                m.NAV1IDENT.setColor(0., 1., 0.);
            } else {
                m.NAV1SELECTED.setColor(1., 1., 1.);
                m.NAV1IDENT.setColor(1., 1., 1.);
            }, 1, 0);
        setlistener("instrumentation/nav[1]/serviceable",
            serviceableListener([m.NAV2FREQ,], [m.NAV2FAIL,]), 1, 0);
	    setlistener("instrumentation/nav[1]/frequencies/standby-mhz",
	        textListener(m.NAV2STANDBY, fmtnav), 1, 0);
	    setlistener("instrumentation/nav[1]/frequencies/selected-mhz",
	        textListener(m.NAV2SELECTED, fmtnav), 1, 0);
	    setlistener("instrumentation/nav[1]/nav-id",
	        textListener(m.NAV2IDENT, fmtident), 1, 0);
	    setlistener("instrumentation/nav[1]/in-range",
	        serviceableListener([m.NAV2IDENT,], []), 1, 0);
        setlistener("instrumentation/FarminTemp/nav1selected",
            serviceableListener([m.NAV1CURSOR, m.NAV1SWAP,],
                [m.NAV2CURSOR, m.NAV2SWAP], 1, 0));
        setlistener("instrumentation/FarminTemp/cdi-display", func(node)
            if (node.getValue() == "nav2") {
                m.NAV2SELECTED.setColor(0., 1., 0.);
                m.NAV2IDENT.setColor(0., 1., 0.);
            } else {
                m.NAV2SELECTED.setColor(1., 1., 1.);
                m.NAV2IDENT.setColor(1., 1., 1.);
            }, 1, 0);

        var fmtcom = func(f) sprintf("%7.3f", f);
        setlistener("instrumentation/comm[0]/serviceable",
            serviceableListener([m.COM1FREQ,], [m.COM1FAIL,]), 1, 0);
	    setlistener("instrumentation/comm[0]/frequencies/standby-mhz",
	        textListener(m.COM1STANDBY, fmtcom), 1, 0);
	    setlistener("instrumentation/comm[0]/frequencies/selected-mhz",
	        textListener(m.COM1SELECTED, fmtcom), 1, 0);
        setlistener("instrumentation/comm[1]/serviceable",
            serviceableListener([m.COM2FREQ,], [m.COM2FAIL,]), 1, 0);
	    setlistener("instrumentation/comm[1]/frequencies/standby-mhz",
	        textListener(m.COM2STANDBY, fmtcom), 1, 0);
	    setlistener("instrumentation/comm[1]/frequencies/selected-mhz",
	        textListener(m.COM2SELECTED, fmtcom), 1, 0);
        setlistener("instrumentation/FarminTemp/com1selected",
            serviceableListener([m.COM1CURSOR, m.COM1SWAP,],
                [m.COM2CURSOR, m.COM2SWAP], 1, 0));

        setlistener("environment/temperature-degc",
            textListener(m.OATVAL, func(f) sprintf("%+3.0f°C", f)), 1, 0);
        setlistener("instrumentation/clock/indicated-string",
            textListener(m.LCLVAL, nil), 1, 0);
        setlistener("instrumentation/transponder/id-code",
            textListener(m.XPDRVAL, func(i) sprintf("%04i", i)), 1, 0);
        setlistener("instrumentation/transponder/inputs/mode",
            textListener(m.XPDRMODE, func(mode)
                ["OFF", "STBY", "TEST", "GND", "ON", "ALT"][mode]), 1, 0);

        return m;
    },
};

var updater = func(){
    screen1.PFD.updateAi();
    screen1.PFD.updateSpeed();
    screen1.PFD.UpdateHeading();
    screen1.PFD.updateAlt();
    screen1.PFD.updateSlipSkid();
    screen1.PFD.updateVSI();
    screen1.PFD.updateGS();
    screen1.PFD.updateControls();
    screen1.PFD.updatePerformance();
    settimer(func updater(), 0.1);
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
    setprop("instrumentation/FarminGDU104X/display-brightness-norm", 0.5);
    setprop("instrumentation/FarminFG1000/Lightmap", "5");
}, 1, 0);
