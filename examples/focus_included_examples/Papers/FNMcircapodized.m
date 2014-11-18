% Script to evaluate the times and errors for a 2.5 lambda radius piston 
% (as in the FNM circle paper published in JASA in 2003) with the apodized
% FNM expression.


datestr(now)

f0 = 2.5e6; % excitation frequency
% atten = 0; % no attenuation
soundspeed = 1500; % m/s
lambda = soundspeed / f0; % wavelength
radius = 2.5 * lambda; % transducer radius

% create the transducer object
transducer=get_circ(radius,[0 0 0 ], [0 0 0], 4);

% create the data structure that specifies the attenuation value, etc.
lossless = set_medium('lossless');

% define the computational grid
% dx = lambda / 4;
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
% ps = set_coordinate_grid([dx 0 dz],0,0,ymin,ymax,zmin,zmax); % on axis only

ndiv = 10;
dflag = 0;
tic
pfnmapodized = fnm_cw_apodized(transducer,ps,lossless,ndiv,f0,dflag);
toc

tic
pfnm = fnm_cw(transducer,ps,lossless,ndiv,f0,dflag);
toc

nx = size(pfnmapodized, 1);
if nx > 1,
% show the pressure field
figure(1)
mesh(z*1000, x*1000, abs(squeeze(pfnmapodized))/max(max(abs(squeeze(pfnmapodized)))))
xlabel('axial distance (mm)')
ylabel('radial distance (mm)')
zlabel('normalized pressure')
title('apodized')

figure(2)
mesh(z*1000, x*1000, abs(squeeze(pfnm))/max(max(abs(squeeze(pfnm)))))
xlabel('axial distance (mm)')
ylabel('radial distance (mm)')
zlabel('normalized pressure')
title('uniformly excited')

else
    figure(2)
    plot(z*1000, abs(squeeze(pfnmapodized)))
end


