FNM TSD Example
width = 1e-3;
height = 5e-3;
elements_x = 32;
elements_y = 1;
kerf = 4e-4;
transducer_array = create_rect_planar_array(elements_x, elements_y, width, height, ...
		kerf, kerf);
draw_array(transducer_array);
This sets up our transducer array with 20 1 mm x 3 mm elements spaced
0.5mm edge-to-edge.
define_media();
fs = 5e6;
f0 = 1e6;
ncycles = 3;
lambda = (lossless.soundspeed / f0);
deltat = 1/fs;
xmin = -(2*width + kerf) * (elements_x/2+1);
xmax = (2*width + kerf) * (elements_x/2+1);
ymin = 0;
ymax = 0;
zmin = 0;
zmax = 15 * lambda;
focus_x = 0;
focus_y = 0;
focus_z = 6 * lambda;
xpoints = 200;
ypoints = 1;
zpoints = 200;
delta = [(xmax-xmin)/xpoints (ymax-ymin)/ypoints (zmax-zmin)/zpoints];
coord_grid=set_coordinate_grid(delta, xmin, xmax, ymin, ymax, zmin, zmax);
[tmin, tmax] = impulse_begin_and_end_times(transducer_array, coord_grid, lossless); t = tmin:deltat:tmax;
time_struct = set_time_samples(deltat, tmin, tmax);
This sets up our coordinate grid to cover the width of the transducer
array on the x axis and from 0 to 15 wavelengths on the z axis. This code
also sets up a time sampling structure that tells fnm_tsd to sample from
t=0 to t=2 periods at intervals of the period of the sampling frequency
(5MHz). Now for the excitation function.

input_func = set_excitation_function(2, f0, ncycles/f0, 0);
This sets our excitation function to be a Hanning weighted tone burst
with an amplitude of 1 and center frequency of f0 (1MHz). See the
documentation for set_excitation_function for details on how FOCUS
handles excitation functions. The next step is to focus the array.
disp(['Focusing array at (', num2str(focus_x), ', ', num2str(focus_y), ...
', ', num2str(focus_z), ')']);
transducer_array = set_time_delays(transducer_array, focus_x, ...
focus_y, focus_z, lossless, fs);
Now we run the FNM TSD function and display the output.
ndiv=4;
tic();
disp('Calculating pressure field...');
p_tsd=transient_pressure(transducer_array, coord_grid, lossless, time_struct, ndiv, input_func);
disp(['Simulation complete in ', num2str(toc()), ' seconds.'])
maxpressure = max(max(max(max(p_tsd))));
nt = size(p_tsd, 4);
x = xmin:delta(1):xmax;
y = ymin:delta(2):ymax;
z = zmin:delta(3):zmax;
figure();
for it = 1:nt,
    mesh(z*100, x*100, squeeze(p_tsd(:, :, :, it)))
    title(['FNM TSD Example, t = ', sprintf('%0.3f',(it/fs) * 1e6), '\mu','s'])
    zlabel('pressure (Pa)')
    xlabel('z (cm)')
    ylabel('x (cm)')
    temp=axis();
    temp(5)=-maxpressure;
    temp(6)=maxpressure;
    axis(temp);
    drawnow
end
