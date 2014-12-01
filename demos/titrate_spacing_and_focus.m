% Script to run through different spacings and focus.

function titrate_spacing_and_focus()
    % Structured as a function so that we can write helper functions in the
    % same file.

    % Constant of 1 element in y-direction.
    elements_y = 1;

    % Curvature to match human skull.
    r_curv = 6e-2;

    % Define media variables.
    define_media();

    % Set stimulation frequency.
    f0 = 4e6;

    num_elements = 100;

    % Set the focus target.
    focus_x = 0;
    focus_y = 0;
    focus_z = 1e-2; % 2e-2; % 1cm

    element_width = 1e-5;

    % Try all combinations of spacing and focus.
    spacing_list = [
        5e-5
        1e-4
        5e-4
        1e-3
        5e-3
    ];

    focus_z_list = [
        1e-2
        2e-2
        3e-2
        4e-2
        5e-2
    ];

    % Dimensions of subplots, i.e. how many plots to show.
    subplot_dims = [length(spacing_list) length(focus_z_list)];

    figure();
    % Main title.
    text(0.5, 1,'\bf Spacing vs Focus Titration','HorizontalAlignment' , ...
            'center', 'VerticalAlignment', 'top');

    for spacing_idx = 1:length(spacing_list)
        for focus_z_idx = 1:length(focus_z_list)
            spacing = spacing_list(spacing_idx);
            focus_z = focus_z_list(focus_z_idx);
            subplot_idx = (spacing_idx - 1) * length(focus_z_list) + ...
                    focus_z_idx;

            % Decrement num_elements until fits within curvature.
            % Based on error-catching code in create_rect_csa.m.
            c_length = 2*pi*r_curv;
            while (num_elements * 2 * spacing) > (c_length/2)
                num_elements = num_elements - 1;
            end

            transducer_array = create_rect_csa(num_elements, elements_y, ...
                    element_width, element_width, spacing, spacing, r_curv);

            % Uncomment to draw array diagrams only.
            % subplot(subplot_dims(1), subplot_dims(2), subplot_idx);
            % draw_array(transducer_array);
            % title(sprintf('spacing: %g, elements: %g', spacing, num_elements));
            % continue;

            % Caculate single-focus phase.
            transducer_array = find_single_focus_phase(...
                    transducer_array, focus_x, focus_y, focus_z, water, f0, 200);

            % Compuate pressure wave and plot result.
            calc_pw_and_plot(transducer_array, subplot_dims, subplot_idx, ...
                    spacing, num_elements, focus_z);
        end
    end
end


function calc_pw_and_plot(transducer_array, subplot_dims, subplot_idx, ...
        spacing, num_elements, focus)
    % Helper function to compute pressure wave and plot on sublot.

    define_media();

    % Set up the viewport and resolution.
    xmin = -2e-2;
    xmax = 2e-2;

    ymin = 0;
    ymax = 0;

    zmin = -1e-2;
    zmax = 6e-2;

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
    title(sprintf('focus: %g, spacing: %g, elements: %g', ...
            focus, spacing, num_elements));
    xlabel('x (cm)');
    ylabel('z (cm)');
end
