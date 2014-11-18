clc;
fprintf('==========================[ Rayleighsphericalshell.m ]==========================\n\n');
fprintf('This example calculates the continuous-wave pressure for a spherical transducer\n');
fprintf('using the Rayleigh-Sommerfeld Integral. It will output a plot of the pressure,\n');
fprintf('the error of the calculation compared to the number of abscissas, the number\n');
fprintf('of abscissas compared to the execution time, and the error compared to the\n');
fprintf('execution time. Similar figures were used in the FNM circle paper published in\n');
fprintf('JASA in 2004.\n\n');

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

nz = 101; % ok to sample the origin
nx = 61;

if nz > 1,
    dz = 2 * d / (nz - 1);
else
    dz = 0;
end
if nx > 1,
    dx = 2 * a / (nx - 1);
else
    dx = 0;
end

delta = [dx 0 dz];

x = xmin:dx:xmax;
z = zmin:dz:zmax;

ps = set_coordinate_grid(delta, xmin, xmax, ymin, ymax, zmin, zmax);

ndiv = 200;
dflag = 0;
tic
pref=fnm_call(xdcr,ps,lossless,ndiv,f0,dflag);
toc

nabscissas = [1:200];
RStimesphere = zeros(size(nabscissas));
RSerrorsphere = zeros(size(nabscissas));
for ndiv = 1:length(nabscissas)
    fprintf('Calculating pressure for ndiv = %i\n', nabscissas(ndiv));
    tic
    prs=rayleigh_cw(xdcr,ps,lossless,nabscissas(ndiv),f0,dflag);
    RStimesphere(ndiv) = toc;
    RSerrorsphere(ndiv) = max(max(max(abs(pref - prs))))/max(max(max(abs(pref))));
end

% plot the times
figure(1)
plot(nabscissas, RStimesphere)
xlabel('number of abscissas');
ylabel('time (s)');

% plot the errors
figure(2)
semilogy(nabscissas, RSerrorsphere)
xlabel('number of abscissas');
ylabel('normalized error');

% plot time vs. error
figure(3)
semilogy(RStimesphere, RSerrorsphere)
xlabel('time (s)');
ylabel('normalized error');

% plot the pressures
if nx > 1 & nz > 1,
    figure(4);
    mesh(z*1000, x*1000, abs(squeeze(pref))/max(max(abs(squeeze(pref)))));
    title('Fast Nearfield Method Result');
    xlabel('z (mm)');
    ylabel('x (mm)');
    zlabel('normalized pressure');

    figure(5);
    mesh(z*1000, x*1000, abs(squeeze(prs))/max(max(abs(squeeze(prs)))));
    title('Rayleigh Sommerfeld Result');
    xlabel('z (mm)');
    ylabel('x (mm)');
    zlabel('normalized pressure');
end

datestr(now)