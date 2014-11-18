% Example based on FDTSD paper
lossless = set_medium('lossless');

f0 = 5e6;
pw = 4/f0;

lambda = lossless.soundspeed/f0;
% Set up transducer
a = 1e-3;
xdc = get_circ(a);

fs = 100e6;
dt = 1/fs;

% Coordinate grids
point_spacing = 200e-6;
xmin = -(20/2)*point_spacing;
xmax = -xmin;

ymin = -(20/2)*point_spacing;
ymax = -ymin;

x = xmin:point_spacing:xmax;
y = ymin:point_spacing:ymax;

nx = length(x);
ny = length(y);

z1 = lambda/2;
z2 = 10 * lambda;

coord_grid_1 = set_coordinate_grid([point_spacing, point_spacing, 0], xmin, xmax, ymin, ymax, z1, z1);
coord_grid_2 = set_coordinate_grid([point_spacing, point_spacing, 0], xmin, xmax, ymin, ymax, z2, z2);

% Time samples
[tmin1, tmax1] = impulse_begin_and_end_times(xdc, coord_grid_1, lossless);
[tmin2, tmax2] = impulse_begin_and_end_times(xdc, coord_grid_2, lossless);

time_samples_1 = set_time_samples(dt, tmin1, tmax1);
time_samples_2 = set_time_samples(dt, tmin2, tmax2);

% Excitation function
tsd_ef = set_excitation_function('hann pulse', f0, pw);
ef_signal = get_excitation_function(tsd_ef, dt);
fdtsd_ef_full = set_excitation_function(ef_signal, dt, pw);
fdtsd_ef_102 = set_excitation_function(ef_signal, dt, pw, 1e-2);
fdtsd_ef_103 = set_excitation_function(ef_signal, dt, pw, 1e-3);

% Calculate
p_ref = fnm_tsd(xdc, coord_grid_1, lossless, time_samples_1, 300, tsd_ef);
ndiv = 1:125;
error_full = zeros(1,125);
error_102 = zeros(1,125);
error_103 = zeros(1,125);

time_full = zeros(1,125);
time_102 = zeros(1,125);
time_103 = zeros(1,125);

for i = 1:125
    fprintf('Calculating for ndiv = %i\n', ndiv(i));
    tic();
    p_fdtsd = fnm_tsd(xdc, coord_grid_1, lossless, time_samples_1, ndiv(i), fdtsd_ef_full);
    time_full(i) = toc();
    
    tic();
    p_fdtsd_102 = fnm_tsd(xdc, coord_grid_1, lossless, time_samples_1, ndiv(i), fdtsd_ef_102);
    time_102(i) = toc();
    
    tic();
    p_fdtsd_103 = fnm_tsd(xdc, coord_grid_1, lossless, time_samples_1, ndiv(i), fdtsd_ef_103);
    time_103(i) = toc();
    
    for ix = 1:nx
        for iy = 1:ny
            diff_f = p_fdtsd(ix,iy,1,:)-p_ref(ix,iy,1,:);
            diff_102 = p_fdtsd_102(ix,iy,1,:)-p_ref(ix,iy,1,:);
            diff_103 = p_fdtsd_103(ix,iy,1,:)-p_ref(ix,iy,1,:);
            
            error_full(i) = max(error_full(i), sqrt(dot(diff_f,diff_f))/max(sqrt(dot(p_ref(ix,iy,1,:),p_ref(ix,iy,1,:)))));
            error_102(i) = max(error_102(i), sqrt(dot(diff_102,diff_102))/max(sqrt(dot(p_ref(ix,iy,1,:),p_ref(ix,iy,1,:)))));
            error_103(i) = max(error_103(i), sqrt(dot(diff_103,diff_103))/max(sqrt(dot(p_ref(ix,iy,1,:),p_ref(ix,iy,1,:)))));
        end
    end
end

figure(1);
loglog(time_full, error_full, 'k'); hold on;
loglog(time_102, error_102, 'b');
loglog(time_103, error_103, 'r');
legend('FDTSD - All frequencies', 'FDTSD e = 10^-^2', 'FDTSD e = 10^-^3');
xlabel('time (s)');
ylabel('error');