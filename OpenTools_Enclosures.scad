// OpenTools_Enclosures.scad
// OpenSCAD library for sensor / PCB enclosures
// (C) 2017, Reinhold Kainhofer, Open Tools
// office@open-tools.net, https://www.open-tools.net/
// License: This work is licensed under a Creative Commons Attribution 4.0 International License.
//
// Features:
// * roundedbox(dim, r): Rounded boxes
// * pcbbox(dim, r, innerr, w, top, ridge): Rounded PCB enclosure, with bottom and top part (height given by top)
// * pcbmount(type, pos, dia, len, innerdia, holedia, pcbthick, screwdia): PCB mount (type="screw"/"clip"/
// * pcbscrew(pos, dia, innerdia, len): Screw mount inside the box to screw a PCB to the enclosure
// * pcbstackon(pos, dia, len, holedia, pcbthick): Stack-on mount inside the screw to hold a PCB
// * boxscrew(pos, dia, innerdia, screwdia, len): Screw holder to screw the top and bottom parts of the enclosure together
// * boxcutout(...): Cut out parts of the box

$fn=25;

module roundedbox(dim, r=2) {
  minkowski() { // rounded corners
    translate([r,r,r]) cube(dim-[2*r, 2*r, 2*r]);
    sphere(r);
  };
}


module pcbbox(dim, r=2, innerr=0, w=2, top=10, ridge=2, ridgeratio=1/3) {
  offset = [0, dim[1]+10, 0];
    
  difference() { // Cut out interior
    union() {
      difference() {
        roundedbox(dim, r);
        translate([-1,-1,dim[2]-top]) cube(dim+[2,2,0]); // Cut off top
      };
      
      difference() {
        translate((1-ridgeratio)*[w, w, w]) roundedbox(dim-2*(1-ridgeratio)*[w, w, w], ridgeratio*r);
        translate([-1,-1,dim[2]-top+ridge]) cube(dim+[2,2,0]); // Cut off top of ridge
      }
    };
    translate([w, w, w]) roundedbox(dim-2*w*[1,1,1], innerr); // Cut out interior
  }
  
  difference() { // Cut off top
    translate(offset) {
      difference() {
        roundedbox(dim, r);
        translate([-1,-1,top]) cube(dim+[2,2,0]);
      }
    };

    difference() {
      translate(offset + (1-ridgeratio)*[w, w, w]) roundedbox(dim-2*(1-ridgeratio)*[w, w, w], ridgeratio*r);
      translate(offset + [-1,-1,-dim[2]+top-ridge]) cube(dim+[2,2,0]); // Cut off top of ridge
    };
    translate(offset + [w, w, w]) roundedbox(dim-2*[w, w, w], innerr); // Cut out interior
  }
}

module pcbmount(type="screw", pos, dia=2, innerdia=1, len=10, w=2, pcbthick=2) {
  translate([pos[0], pos[1], w]) difference() {
    if (type=="screw") {
      difference() {
        cylinder(h=len, d=dia);
        cylinder(h=len+0.01, d=innerdia);
      }
    } else if (type=="clip") {
      
    } else if (type=="stack") {
      cylinder(h=len, d=dia);
      cylinder(h=len+pcbthick, d=innerdia);
    } else {
      echo ("Unknown pcbmount ", type=type, " ignoring call.");
    }
  }
}

//module pcbspacer(axis="x", pos, l, l1, l2, h, h1, h2, w=0.5) {
module pcbspacer(axis="x", pos, l, h, w=0.5, boxw=2, dim) {
  if (axis=="x") {
    if (l>0) {
      translate([pos-w/2, boxw, boxw]) cube([w, l, h]);
    } else {
      translate([pos-w/2, dim[1]-boxw+l, boxw]) cube([w, -l, h]);
    }
  } else if (axis=="y") {
    if (l>0) {
      translate([boxw, pos-w/2, boxw]) cube([l, w, h]);
    } else {
      translate([dim[0]-boxw+l, pos-w/2, boxw]) cube([-l, w, h]);
    }
  } else if (axis=="z") {
    echo ("pcbspacer with axis=z not yet implemented...");
  } else {
      echo ("Unknown pcbspacer axis ", axis, " ignoring call.");
  }
}

module pcbspacersym(axis="x", pos, l, h, w=0.5, boxw=2, dim) {
  union() {
    pcbspacer(axis, pos, l, h, w, boxw, dim);
    pcbspacer(axis, pos, -l, h, w, boxw, dim);
  }
}  
module pcbspacerl(axis="x", pos, l1, l2, h1, h2, w=0.5, boxw=2, dim) {
  union() {
    pcbspacer(axis, pos, l1, h2, w, boxw, dim);
    pcbspacer(axis, pos, l2, h1, w, boxw, dim);
  }
}  
module pcbspacerlsym(axis="x", pos, l1, l2, h1, h2, w=0.5, boxw=2, dim) {
  union() {
    pcbspacer(axis, pos, l1, h2, w, boxw, dim);
    pcbspacer(axis, pos, l2, h1, w, boxw, dim);
    pcbspacer(axis, pos, -l1, h2, w, boxw, dim);
    pcbspacer(axis, pos, -l2, h1, w, boxw, dim);
  }
}  
            
        

difference() {
  union() {
    pcbbox(dim=[50,30,30], r=2, innerr=0.3, w=2, top=25);
    pcbmount(pos=[10, 20], dia=3 , innerdia=1, len=3, w=2);
    pcbmount(pos=[40, 20], dia=5, innerdia=2, len=3, w=2);
    pcbmount(type="stack", pos=[10, 10], dia=5, innerdia=3, len=3, w=2);
    pcbmount(pos=[20, 20], dia=3, innerdia=1, len=5, w=2);
    pcbmount(type="stack", pos=[30, 20], dia=3, innerdia=1, len=5, w=2, pcbthick=2);
    pcbmount(type="something", pos=[30, 20], dia=3, innerdia=1, len=5, w=2, pcbthick=2);
    pcbspacerl(axis="x", pos=15, l1=3, l2=1, h1=5, h2=3, 
//    pcbspacer(axis="x", pos=15, l=3, h=3, w=0.5, boxw=2, dim=[50,30,30]);
//    pcbspacer(axis="x", pos=15, l=1, h=5, w=0.5, boxw=2, dim=[50,30,30]);
//    pcbspacer(axis="x", pos=15, l=-2, h=3, w=0.5, boxw=2, dim=[50,30,30]);
//    pcbspacer(axis="x", pos=35, l=2, h=3, w=0.5, boxw=2, dim=[50,30,30]);
//    pcbspacer(axis="y", pos=5, l=2, h=3, w=0.5, boxw=2, dim=[50,30,30]);
//    pcbspacer(axis="y", pos=5, l=-2, h=3, w=0.5, boxw=2, dim=[50,30,30]);
    pcbspacersym(axis="y", pos=25, l=2, h=3, w=0.5, boxw=2, dim=[50,30,30]);
  };
  
};