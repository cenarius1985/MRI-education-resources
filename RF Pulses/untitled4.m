% Configuración de la figura
figure('Position', [100 100 800 600]);

% Parámetros de tiempo y espacio
t = linspace(0, 10, 100);
z = linspace(-10, 10, 7);  % 7 posiciones diferentes en z
dt = t(2) - t(1);

% Parámetros del campo magnético y gradiente
B0 = 1.5;  % Campo principal en Tesla
Gz = 0.01; % Gradiente en T/m
gamma = 42.577e6;  % Razón giromagnética para protones (Hz/T)

% Frecuencia de referencia (frecuencia del pulso RF)
w_rf = gamma * B0;  % Frecuencia central
slice_pos = 0;  % Posición del corte deseado

% Inicializar el GIF
filename = 'spin_resonance.gif';
firstframe = true;

% Colores para los espines
colors = jet(length(z));

% Crear la animación
for time_idx = 1:length(t)
    clf;
    
    % Subplot para la vista lateral (plano x-z)
    subplot(2,1,1)
    hold on
    grid on
    
    % Dibujar línea de corte
    plot([-1 1], [slice_pos slice_pos], 'r--', 'LineWidth', 2)
    
    % Para cada posición en z
    for z_idx = 1:length(z)
        % Calcular frecuencia de precesión local
        B_local = B0 + Gz * z(z_idx);
        w_local = gamma * B_local;
        
        % Calcular fase del espín
        phase = w_local * t(time_idx);
        
        % Calcular posición del espín
        x = 0.5 * cos(phase);
        y = 0.5 * sin(phase);
        
        % Dibujar el espín
        plot(x, z(z_idx), '.', 'Color', colors(z_idx,:), 'MarkerSize', 30)
        
        % Dibujar vector de magnetización
        quiver(0, z(z_idx), x, 0, 0, 'Color', colors(z_idx,:), 'LineWidth', 2)
        
        % Calcular diferencia con la frecuencia RF
        dw = abs(w_local - w_rf);
        
        % Si está en resonancia (cerca de la frecuencia RF)
        if abs(z(z_idx)) < 1
            plot(x, z(z_idx), 'ro', 'MarkerSize', 35)
        end
    end
    
    xlabel('X')
    ylabel('Z (Posición)')
    title('Vista Lateral - Plano XZ')
    axis([-1 1 -10 10])
    
    % Subplot para la vista superior (plano x-y) del corte seleccionado
    subplot(2,1,2)
    hold on
    grid on
    
    % Para cada posición en z cerca del corte
    for z_idx = 1:length(z)
        if abs(z(z_idx)) < 1  % Solo mostrar espines cerca del corte
            % Calcular frecuencia local
            B_local = B0 + Gz * z(z_idx);
            w_local = gamma * B_local;
            
            % Calcular posición del espín
            phase = w_local * t(time_idx);
            x = 0.5 * cos(phase);
            y = 0.5 * sin(phase);
            
            % Dibujar el espín
            plot(x, y, 'ro', 'MarkerSize', 30)
            quiver(0, 0, x, y, 0, 'r', 'LineWidth', 2)
        end
    end
    
    % Dibujar círculo de referencia
    theta = linspace(0, 2*pi, 100);
    plot(0.5*cos(theta), 0.5*sin(theta), 'k--')
    
    xlabel('X')
    ylabel('Y')
    title('Vista Superior - Plano XY (Corte Seleccionado)')
    axis([-1 1 -1 1])
    axis equal
    
    % Añadir información del gradiente
    annotation('textbox', [0.15 0.95 0.7 0.05], ...
        'String', {sprintf('Tiempo: %.2f ms', t(time_idx)), ...
        sprintf('Gradiente: %.3f T/m', Gz), ...
        'Rojo = Espines en Resonancia'}, ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
    
    % Capturar y guardar el frame
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if firstframe
        imwrite(imind,cm,filename,'gif','LoopCount',inf,'DelayTime',0.1);
        firstframe = false;
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.1);
    end
end