% Demo of simulating off axis.

function [pw] = simulate_off_axis()
    % Structured as a function so that we can write helper functions in the
    % same file.

    % Setup the transducer array.
    width = 5e-5;
    height = 5e-5;
    elements_x = 800;
    elements_y = 1;
    kerf = 5e-5;
    r_curv = 6e-2;
    transducer_array = create_rect_csa(...
            elements_x, elements_y, width, height, kerf, kerf, r_curv);

    % figure();
    % draw_array(transducer_array);

    % Set up the media. By default we'll use water.
    define_media();

    %%% Spot 1
    focus_x = 1.75e-2;
    focus_y = 0;
    focus_z = 0.75e-2;
    freq = 4e6;
    target_1_array = find_single_focus_phase(...
            transducer_array, focus_x, focus_y, focus_z, water, freq, 200);
    target_1_array = target_1_array(600:700);
    pw1 = calc_pw(target_1_array, freq);

    %%% Spot 2
    focus_x = 0;
    focus_y = 0;
    focus_z = 0.75e-2;
    freq = 4e6;
    target_2_array = find_single_focus_phase(...
            transducer_array, focus_x, focus_y, focus_z, water, freq, 200);
    target_2_array = target_2_array(350:450);
    pw2 = calc_pw(target_2_array, freq);

    %%% Trick to highlight the whole array.
    focus_x = 0e-2;
    focus_y = 0;
    focus_z = 0;
    freq = 5e7;
    transducer_array = find_single_focus_phase(...
            transducer_array, focus_x, focus_y, focus_z, water, freq, 200);
    % pw3 = calc_pw(transducer_array, freq);

    % Add the pressure waves and plot.
    % pw = pw1 + pw2 + pw3;
    pw = pw1 + pw2;
    % pw = pw1;
    plot_pw(pw)
end


function [x, y, z, coord_grid] = get_x_y_z_coord_grid()
    % Helper to get coordinates.
    define_media();

    % Set up the viewport and resolution.
    xmin = -4e-2;
    xmax = 4e-2;

    ymin = 0;
    ymax = 0;

    zmin = -0.5e-2;
    zmax = 2.5e-2;

    xpoints = 500;
    ypoints = 1;
    zpoints = 500;

    dx = (xmax-xmin)/xpoints;
    dy = (ymax-ymin)/ypoints;
    dz = (zmax-zmin)/zpoints;
    delta = [dx dy dz];

    x = xmin:dx:xmax;
    y = ymin:dy:ymax;
    z = zmin:dz:zmax;

    coord_grid = set_coordinate_grid(delta, xmin, xmax, ymin, ymax, zmin, zmax);
end


function [p_cw] = calc_pw(transducer_array, freq)
    % Helper function to compute pressure wave and plot on sublot.

    define_media();

    [x, y, z, coord_grid] = get_x_y_z_coord_grid();

    % Run the simulation to calculate the pressure field.
    ndiv=3;
    tic();
    disp('Calculating pressure field...');
    p_cw=cw_pressure(transducer_array, coord_grid, water, ndiv, freq);
    disp(['Simulation complete in ', num2str(toc()), ' seconds.'])
end


function plot_pw(p_cw)
    [x, y, z, coord_grid] = get_x_y_z_coord_grid();
    h = pcolor(x*100,z*100,rot90(squeeze(abs(p_cw)),3));
    set(h,'edgecolor','none');
    xlabel('x (cm)');
    ylabel('z (cm)');
end

