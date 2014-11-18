% Script to evaluate the times and errors for a 5 lambda radius piston 
% (as in the FNM circle paper published in JASA in 2003) with the Rayleigh
% Sommerfeld integral.
datestr(now)

f0 = 2.5e6; % excitation frequency
soundspeed = 1500; % m/s
lambda = soundspeed / f0; % wavelength
radius = 2.5 * lambda; % transducer radius

% create the transducer object
transducer=get_circ(radius,[0 0 0 ], [0 0 0], 4);

% create the data structure that specifies the attenuation value, etc.
lossless = set_medium('lossless');

% define the computational grid
dz = lambda / 8;
nx = 121;
ny = 1;
nz = 101;
xmin = -3e-3; % -3mm
xmax = 3e-3; % 3mm
dx = (xmax - xmin) / (nx  - 1);
ymin = 0;
ymax = 0;
zmin = 0.0;
zmax = (nz - 1) * dz;
x = xmin:dx:xmax;
y = ymin:0:ymax;
z = zmin:dz:zmax;
ps = set_coordinate_grid([dx 0 dz],xmin,xmax,ymin,ymax,zmin,zmax);

ndiv = 40;
dflag = 0;
tic
prs=rayleigh_cw_apodized(transducer,ps,lossless,ndiv,f0,dflag);
toc

% show the pressure field
nx = size(prs, 1);
if nx > 1,
    figure(1)
    mesh(z*1000, x*1000, abs(squeeze(prs))/max(max(abs(squeeze(prs)))))
    xlabel('axial distance (mm)')
    ylabel('radial distance (mm)')
    zlabel('normalized pressure')
else
    figure(1)    
    plot(z*1000, abs(squeeze(prs)))
end
