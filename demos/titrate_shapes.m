% Script to test various shapes.

figure();

% Common params.
nelex = 16;
neley = 2;
element_width = 1e-3; % 1 um
element_height = 5e-3; % 1 um
element_radius = 1e-3; % 1 cm
kerf = 1e-3; % 1 cm
kerf_x = kerf;
kerf_y = kerf;
r_curv = 6e-2;
center = [0 0 0];

% Dimensions of subplots, i.e. how many plots to show.
subplot_dims = [3 3];

% cylindrical section array of circular transducers
subplot(subplot_dims(1), subplot_dims(2), 1);
circ_csa_array = create_circ_csa(...
        elements_x, elements_y, element_radius, kerf, kerf, r_curv);
draw_array(circ_csa_array);
title('circ\_csa');

% cylindrical section array of rectangular transducers.
subplot(subplot_dims(1), subplot_dims(2), 2);
rect_csa_array = create_rect_csa(...
        nelex, neley, element_width, element_height, kerf_x, kerf_y, r_curv);
draw_array(rect_csa_array);
title('rect\_csa');

% cylindrical section array of rectangular transducers.
subplot(subplot_dims(1), subplot_dims(2), 3);
nelecirc = nelex;
rect_enclosed_csa = create_rect_enclosed_csa(...
        nelecirc, neley, element_width, element_height, kerf_y, r_curv);
draw_array(rect_enclosed_csa);
title('rect\_enclosed\_csa');

% planar array of rectangular transducers
subplot(subplot_dims(1), subplot_dims(2), 4);
rect_planar_array = create_rect_planar_array(...
        nelex, neley, element_width, element_height, kerf_x, kerf_y, center);
draw_array(rect_planar_array);
title('rect\_planar\_array');

% spherical section array of circular transducers
subplot(subplot_dims(1), subplot_dims(2), 5);
nrow = 16;
ang_open = pi / 4;
circ_ssa_radius = 1e-4;
circ_ssa = create_circ_ssa(circ_ssa_radius, r_curv, nrow, ang_open);
draw_array(circ_ssa);
title('circ\_ssa');

% planar array of spherical shell transducers
subplot(subplot_dims(1), subplot_dims(2), 6);
spherical_shell_planar_array = create_spherical_shell_planar_array(...
        nelex, neley, element_radius, r_curv, kerf_x, kerf_y, center);
draw_array(spherical_shell_planar_array);
title('spherical\_shell\_planar\_array');

% spherical section array of rectangular transducers
subplot(subplot_dims(1), subplot_dims(2), 7);
rect_ssa = create_rect_ssa(...
        element_width, element_height, r_curv, nrow, ang_open);
draw_array(rect_ssa);
title('rect\_ssa');

% array of concentric ring transducers
subplot(subplot_dims(1), subplot_dims(2), 8);
el_count = 16;
concentric_ring_array = create_concentric_ring_array(...
        el_count, element_width, kerf);
draw_array(concentric_ring_array);
title('concentric\_ring\_array');

% curved strip array of rectangular elements
subplot(subplot_dims(1), subplot_dims(2), 9);
rect_curved_strip_array = create_rect_curved_strip_array(...
        elements_x, elements_y, element_width, element_height, kerf, r_curv);
draw_array(rect_curved_strip_array);
title('rect\_curved\_strip\_array');
