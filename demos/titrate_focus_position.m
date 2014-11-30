% Script to run through different frequencies to observe effect.

function titrate_focus_position()
    % Structured as a function so that we can write helper functions in the
    % same file.

    % Setup the transducer array.
    width = 5e-4;
    height = 5e-4;
    elements_x = 100;
    elements_y = 1;
    kerf = 5e-4;
    r_curv = 6e-2;
    transducer_array = create_rect_csa(...
            elements_x, elements_y, width, height, kerf, kerf, r_curv);

    figure();
    draw_array(transducer_array);

    % Set up the media. By default we'll use water.
    define_media();

    % Set the focus target.
    focus_x = 0;
    focus_y = 0;
    focus_z = 1e-2; % 2e-2; % 1cm

    freq = 1e6;

    focus_z_list = [
        5e-5
        1e-2
        2e-2
        3e-2
        4e-2
        5e-2
        6e-2
        7e-2
        8e-2
    ];

    % Dimensions of subplots, i.e. how many plots to show.
    figure();
    subplot_dims = [3 3];
    for i = 1:length(focus_z_list)
        focus_z = focus_z_list(i);

        % Caculate single-focus phase.
        transducer_array = find_single_focus_phase(...
                transducer_array, focus_x, focus_y, focus_z, water, freq, 200);

        % Compuate pressure wave and plot result.
        calc_pw_and_plot(transducer_array, subplot_dims, i, focus_z);
    end

    % Main title.
    ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off', ...
            'Visible','off','Units','normalized', 'clipping' , 'off');
    text(0.5, 1,'\bf Frequency Tittration?','HorizontalAlignment' ,'center', ...
            'VerticalAlignment', 'top');
end


function calc_pw_and_plot(transducer_array, subplot_dims, subplot_idx, focus)
    % Helper function to compute pressure wave and plot on sublot.

    define_media();

    % Set up the viewport and resolution.
    xmin = -2e-2;
    xmax = 2e-2;

    ymin = 0;
    ymax = 0;

    zmin = -1e-2;
    zmax = 10e-2;

    xpoints = 300;
    ypoints = 1;
    zpoints = 300;

    dx = (xmax-xmin)/xpoints;
    dy = (ymax-ymin)/ypoints;
    dz = (zmax-zmin)/zpoints;
    delta = [dx dy dz];

    x = xmin:dx:xmax;
    y = ymin:dy:ymax;
    z = zmin:dz:zmax;

    coord_grid = set_coordinate_grid(delta, xmin, xmax, ymin, ymax, zmin, zmax);

    % Run the simulation to calculate the pressure field.
    ndiv=3;
    tic();
    disp('Calculating pressure field...');
    p_cw=cw_pressure(transducer_array, coord_grid, water, ndiv, f0);
    disp(['Simulation complete in ', num2str(toc()), ' seconds.'])

    % Plot the result.
    subplot(subplot_dims(1), subplot_dims(2), subplot_idx);
    h = pcolor(x*100,z*100,rot90(squeeze(abs(p_cw)),3));
    set(h,'edgecolor','none');
    title(sprintf('focus = %g', focus));
    xlabel('x (cm)');
    ylabel('z (cm)');
end
