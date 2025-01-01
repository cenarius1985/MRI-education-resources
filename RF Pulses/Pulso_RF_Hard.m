% Configuración de la figura
figure('Position', [100 100 800 600]);

% No necesitamos VideoWriter para GIF
% Duración del pulso va desde 0.5ms a 2ms
durations = linspace(0.5, 4, 50);

% Parámetros de tiempo
t = linspace(-5, 5, 1000);
f = linspace(-500, 500, 1000);

% Inicializar el GIF
firstframe = true;

for dur_idx = 1:length(durations)
    duration = durations(dur_idx);
    % Limpiar la figura
    clf;
    % Subplot superior para el pulso RF
    subplot(2,1,1);
    hold on;
    % Crear el pulso rectangular
    pulse = zeros(size(t));
    pulse(abs(t) <= duration/2) = 1;
    % Dibujar el pulso
    plot(t, pulse, 'b-', 'LineWidth', 2);
    % Configuración de ejes
    xlabel('Tiempo (ms)');
    ylabel('Amplitud');
    title(sprintf('Pulso RF - Duración: %.2f ms', duration));
    grid on;
    ylim([-0.2 1.2]);
    xlim([-5 5]);
    % Subplot inferior para el espectro de frecuencias
    subplot(2,1,2);
    hold on;
    % Calcular la transformada de Fourier (función sinc)
    bw = 1/(4*duration/1000); % Convertir ms a s para BW en Hz
    spectrum = abs(sinc(f * duration/1000));
    % Normalizar el espectro
    spectrum = spectrum/max(spectrum);
    % Dibujar el espectro
    plot(f, spectrum, 'r-', 'LineWidth', 2);
    % Marcar el ancho de banda
    bw_line = 0.5; % Línea al 50% de la altura máxima
    plot([-bw bw], [bw_line bw_line], 'k--');
    plot([-bw -bw], [0 bw_line], 'k--');
    plot([bw bw], [0 bw_line], 'k--');
    % Añadir texto con el valor del BW
    text(0, bw_line*1.1, sprintf('BW = %.0f Hz', bw), ...
        'HorizontalAlignment', 'center');
    % Configuración de ejes
    xlabel('Frecuencia (Hz)');
    ylabel('Amplitud');
    title('Espectro de Frecuencias');
    grid on;
    ylim([0 1.2]);
    xlim([-500 500]);
    % Añadir la fórmula
    annotation('textbox', [0.15 0.95 0.7 0.05], ...
        'String', 'BW = 1/(4 × Duration)', ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
    
    % Capturar y guardar el frame
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    % Escribir al archivo gif
    if firstframe
        imwrite(imind,cm,'rf_pulse_bw.gif','gif','LoopCount',inf,'DelayTime',0.1);
        firstframe = false;
    else
        imwrite(imind,cm,'rf_pulse_bw.gif','gif','WriteMode','append','DelayTime',0.1);
    end
    
    pause(0.1);
end