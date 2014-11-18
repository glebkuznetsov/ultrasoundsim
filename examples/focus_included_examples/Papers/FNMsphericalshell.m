clc;
fprintf('============================[ FNMsphericalshell.m ]============================\n\n');
fprintf('This example calculates the continuous-wave pressure for a spherical transducer\n');
fprintf('using the Fast Nearfield Method. It will output a plot of the pressure, the\n');
fprintf('error of the calculation compared to the number of abscissas, the number of\n');
fprintf('abscissas compared to the execution time, and the error compared to the\n');
fprintf('execution time.\n\n');

lossless = set_medium('lossless');

f = 1e6;
lambda = lossless.soundspeed / f;
omega = 2 * pi * f;
k = 2 * pi / lambda;

R = 5 * sqrt(2) * lambda;
a = 5 * lambda;
d = sqrt(R^2 - a^2);
phi0 = asin(a/R);

xdcr = get_spherical_shell(a,R);
xmin = -a;
xmax = a;
ymin = 0;
ymax = 0;
zmin = -d + R;
zmax = d + R;

nz = 201; % ok to sample the origin
nx = 101;


if nx > 1,
    dx = 2 * a / (nx - 1);
else
    dx = 0;
end

if nz > 1,
    dz = 2 * d / (nz - 1);
else
    dz = 0;
end
delta = [dx 0 dz];

x = xmin:dx:xmax;
y = ymin:dx:ymax;
z = zmin:dz:zmax;

ps = set_coordinate_grid(delta, xmin, xmax, ymin, ymax, zmin, zmax);

ndiv = 200;
dflag = 0;
tic
pref=fnm_call(xdcr,ps,lossless,ndiv,f,dflag);
toc


figure(4)
mesh(abs(squeeze(pref)))

maxndiv = 200;
FNMerrorsphere = zeros(1, maxndiv);
FNMtimesphere = zeros(1, maxndiv);
for ndiv = 1:maxndiv
    tic
    pfnm=fnm_call(xdcr,ps,lossless,ndiv,f,dflag);
    FNMtimesphere(ndiv) = toc;
    FNMerrorsphere(ndiv) = max(max(max(abs(pref - pfnm))))/max(max(max(abs(pref))));
end

figure(1)
plot(FNMtimesphere*1000)
xlabel('number of abscissas');
ylabel('time (ms)');

figure(2)
semilogy(FNMerrorsphere)
xlabel('number of abscissas');
ylabel('normalized error');

figure(3)
semilogy(FNMtimesphere*1000, FNMerrorsphere)
xlabel('time (ms)');
ylabel('normalized error');

figure(4)
mesh(z*1000, x*1000, abs(squeeze(pref)))
xlabel('z (mm)');
ylabel('x (mm)');
zlabel('normalized pressure');