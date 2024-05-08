function lowpass_matlab_simulate()

    path_output = '.\Result';
    
    % ==================== 参数设置 ====================
    
    R = 2.526 * (10^3);    % 2.526K
    C = 1.8 * (10^(-9));   % 1.8nF
    fc = 1 / (2 * pi * R * C);    % 35kHz

    f = 0:100 * 10 ^ 3;
    w = 2 * pi * f;
    H = @(w)1 ./ (1 + 1i * R * C * w);    % 传递函数

    fprintf('[INFO] RC低通滤波器截止频率为: %fHz\n', fc);
    fprintf('[INFO] 电阻值为：%fKΩ\n', (R/1000));
    fprintf('[INFO] 电容值为：%fnF\n', (C * 10^9));

    % ==================== 绘制RC低通滤波器幅频特性 ====================

    p_filter_Hw = figure;
    hold on;
    grid on;
    xlabel(texlabel('f/Hz'));
    ylabel('$$H(j\omega)$$', 'Interpreter', 'latex');
    title('RC幅频特性曲线');

    p_filter_Hw_modi = plot(f, abs(H(w)), fc, abs(H(2 * pi * fc)));
    p_filter_Hw_modi(2).Marker = "+";

    % 绘制截止频率点
    text(fc, abs(H(2 * pi * fc)), ['(', num2str(fc), ', ', num2str(abs(H(2 * pi * fc))), ')'], ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');

    saveas(p_filter_Hw, strcat(path_output, '\RC幅频特性曲线.png'));
    hold off;
    close(p_filter_Hw);

    p_filter_Hw_dB = figure;
    hold on;
    grid on;
    xlabel(texlabel('f/Hz'));
    ylabel('$$H(j\omega)/dB$$', 'Interpreter', 'latex');
    title('RC幅频特性曲线');

    p_filter_Hw_modi = plot(f, 20*log10(abs(H(w))), fc, 20*log10(abs(H(2 * pi * fc))));
    p_filter_Hw_modi(2).Marker = "+";

    % 绘制截止频率点
    text(fc, 20*log10(abs(H(2 * pi * fc))), ['(', num2str(fc), ', ', num2str(20*log10(abs(H(2 * pi * fc)))), ')'], ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');

    saveas(p_filter_Hw_dB, strcat(path_output, '\RC幅频特性曲线dB.png'));
    hold off;
    close(p_filter_Hw_dB);

    % ==================== 生成输入波形 ==================== 

    N = 100000;     % 采样点数
    fs = 10 * 10 ^ 6;    % 10MHz 采样频率
    t = (1 / fs) * (0:N - 1);

    f1 = 20 * 10 ^ 3;    % 20kHz 单音正弦
    f2_1 = 20 * 10 ^ 3;    % 2kHz 三音正弦其一
    f2_2 = 50 * 10 ^ 3;    % 50kHz 三音正弦其二
    f2_3 = 100 * 10 ^ 3;    % 100kHz 三音正弦其三
    f3 = 20 * 10 ^ 3;    % 20kHz 方波

    f1_passband = 1 * 10 ^ 3;    % 1kHz 通带
    f2_passband = 10 * 10 ^ 3;    % 10kHz 通带
    f1_transition = 40 * 10 ^ 3;    % 40kHz 过渡带
    f2_transition = 50 * 10 ^ 3;    % 50kHz 过渡带
    f1_stopband = 100 * 10 ^ 3;    % 10kHz 阻带
    f2_stopband = 200 * 10 ^ 3;    % 200kHz 阻带

    wave_1 = sin(2 * pi * f1 * t);
    wave_2 = sin(2 * pi * f2_1 * t) + sin(2 * pi * f2_2 * t) + sin(2 * pi * f2_3 * t);
    wave_3 = square(2 * pi * f3 * t, 50);

    wave_1_passband = sin(2 * pi * f1_passband * t);
    wave_2_passband = sin(2 * pi * f2_passband * t);
    wave_1_transition = sin(2 * pi * f1_transition * t);
    wave_2_transition = sin(2 * pi * f2_transition * t);
    wave_1_stopband = sin(2 * pi * f1_stopband * t);
    wave_2_stopband = sin(2 * pi * f2_stopband * t);

    % ==================== 绘制三种输入输出波形 ====================

    H_w = tf(1, [R * C 1]);    % 传递函数
    
    draw_wave_result(path_output, t, wave_1, H_w, fs, f1, N, '20kHz单音正弦波');
    draw_wave_result(path_output, t, wave_2, H_w, fs, f2_3, N, '20kHz、50kHz、100kHz三音正弦波');
    draw_wave_result(path_output, t, wave_3, H_w, fs, f3, N, '20kHz方波');

    draw_wave_result(path_output, t, wave_1_passband, H_w, fs, f1_passband, N, [num2str(f1_passband/1000), 'kHz通带正弦波']);
    draw_wave_result(path_output, t, wave_2_passband, H_w, fs, f2_passband, N, [num2str(f2_passband/1000), 'kHz通带正弦波']);
    draw_wave_result(path_output, t, wave_1_transition, H_w, fs, f1_transition, N, [num2str(f1_transition/1000), 'kHz过渡带正弦波']);
    draw_wave_result(path_output, t, wave_2_transition, H_w, fs, f2_transition, N, [num2str(f2_transition/1000), 'kHz过渡带正弦波']);
    draw_wave_result(path_output, t, wave_1_stopband, H_w, fs, f1_stopband, N, [num2str(f1_stopband/1000), 'kHz阻带正弦波']);
    draw_wave_result(path_output, t, wave_2_stopband, H_w, fs, f2_stopband, N, [num2str(f2_stopband/1000), 'kHz阻带正弦波']);


function draw_wave_result(path, t, wave_t, H_w, fs, f_wave, N, title_str)

    out_wave_t = lsim(H_w, wave_t, t);    % 输出波形
    
    % ==================== 时域图 ====================
    p_wave_t = figure;
    
    plot(t, wave_t, t, out_wave_t);
    legend('原始响应', '滤后响应');
    title(strcat(title_str, '时域波形'));
    xlabel(texlabel('t/s'));
    ylabel('幅值');
    if strcmp(title_str, '20kHz、50kHz、100kHz三音正弦波')
        axis([0, (8/(20 * 10 ^ 3)), -1.2*max(wave_t), 1.2*max(wave_t)])
    else
        axis([0, (8/f_wave), -1.2*max(wave_t), 1.2*max(wave_t)])
    end

    saveas(p_wave_t, strcat(path, '\时域波形_', title_str, '.png'));
    close(p_wave_t);

    % ==================== 频域图 ====================
    
    f = (fs/N) * (-N/2:N/2-1);    % 双边频谱

    wave_w = fft(wave_t, N);
    wave_w = (wave_w * 2) / length(wave_w);
    wave_w = fftshift(wave_w);
    wave_w_abs = abs(wave_w);

    out_wave_w = fft(out_wave_t, N);
    out_wave_w = (out_wave_w * 2) / length(out_wave_w);
    out_wave_w = fftshift(out_wave_w);
    out_wave_w_abs = abs(out_wave_w);

    p_wave_w = figure;

    plot(f, wave_w_abs, f, out_wave_w_abs);
    legend('原始响应', '滤后响应');
    title(strcat(title_str, '频域波形'));
    xlabel(texlabel('f/Hz'));
    ylabel('幅值');
    if strcmp(title_str, '20kHz方波')
        axis([-(1.2 * (10^6)), (1.2 * (10^6)), 0, 1.5 * max(wave_w_abs)])    
    else
        axis([-(1.2 * f_wave), (1.2 * f_wave), 0, 1.5 * max(wave_w_abs)])
    end

    hold on;

    [out_max_value, out_max_index] = max(out_wave_w_abs);
    plot(abs(f(out_max_index)), out_max_value, '*');
    text(abs(f(out_max_index)), out_max_value, ['(', num2str(abs(f(out_max_index))), ', ', num2str(out_max_value), ')'], ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');

    hold off;

    saveas(p_wave_w, strcat(path, '\频域波形_', title_str, '.png'));
    close(p_wave_w);

    pass_rate = max(out_wave_w_abs)/max(wave_w_abs);
    fprintf('[INFO] %s的传输系数为: %f\n', title_str, pass_rate);

    % ==================== 功率谱密度 ====================
    
    wave_w_power = wave_w_abs .^ 2;
    out_wave_w_power = out_wave_w_abs .^ 2;
    
    p_power = figure;

    hold on;

    plot(f, wave_w_power, f, out_wave_w_power);
    legend('原始响应', '滤后响应');
    title(strcat(title_str, '功率谱'));    % 这里改成功率谱是为了区分输入和输出波形，要不然两个叠一起
    xlabel(texlabel('f/Hz'));
    ylabel(texlabel('P/W'));
    %axis([-(1.2 * f_wave), (1.2 * f_wave), 0, (1.5 * max(wave_w_power))]);
    if max(wave_w_power) < 0.5
        maxval = 0.5;
    else
        maxval = 1.2 * max(wave_w_power);
    end
    if strcmp(title_str, '20kHz方波')
        axis([-(1.2 * (10^6)), (1.2 * (10^6)), 0, maxval])    
    else
        axis([-(1.2 * f_wave), (1.2 * f_wave), 0, maxval])
    end

    hold off;
    
    saveas(p_power, strcat(path, '\功率谱_', title_str, '.png'));
    close(p_power);

    wave_w_power = wave_w_power / sum(wave_w_power);    % 归一化
    out_wave_w_power = out_wave_w_power / sum(out_wave_w_power);    % 归一化

    p_power = figure;

    plot(f, wave_w_power);
    title(strcat(title_str, '输入波形功率谱密度'));
    xlabel(texlabel('f/Hz'));
    ylabel(texlabel('P/W'));
    if strcmp(title_str, '20kHz方波')
        axis([-(1.2 * (10^6)), (1.2 * (10^6)), 0, 1.5 * max(wave_w_power)])    
    else
        axis([-(1.2 * f_wave), (1.2 * f_wave), 0, 1.5 * max(wave_w_power)])
    end

    hold on;

    [max_value, max_index] = max(wave_w_power);
    plot(abs(f(max_index)), max_value, '*');
    text(abs(f(max_index)), max_value, ['(', num2str(abs(f(max_index))), ', ', num2str(max_value), ')'], ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
    
    hold off;
    
    saveas(p_power, strcat(path, '\功率谱密度_输入波形_', title_str, '.png'));
    close(p_power);

    p_power = figure;

    plot(f, out_wave_w_power);
    title(strcat(title_str, '输出波形功率谱密度'));
    xlabel(texlabel('f/Hz'));
    ylabel(texlabel('P/W'));
    if strcmp(title_str, '20kHz方波')
        axis([-(1.2 * (10^6)), (1.2 * (10^6)), 0, 1.5 * max(out_wave_w_power)])    
    else
        axis([-(1.2 * f_wave), (1.2 * f_wave), 0, 1.5 * max(out_wave_w_power)])
    end

    hold on;

    [out_max_value, out_max_index] = max(out_wave_w_power);
    plot(abs(f(out_max_index)), out_max_value, '*');
    text(abs(f(out_max_index)), out_max_value, ['(', num2str(abs(f(out_max_index))), ', ', num2str(out_max_value), ')'], ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
    
    hold off;
    
    saveas(p_power, strcat(path, '\功率谱密度_输出波形_', title_str, '.png'));
    close(p_power);

    % ==================== 自相关函数 ====================

    [R_wave, maxlags_wave] = xcorr(wave_t, 'unbiased');     % 无偏估计
    [R_outWave, maxlags_outWave] = xcorr(out_wave_t, 'unbiased');
    
    p_xcorr = figure;
    
    plot((maxlags_wave / fs), R_wave / max(R_wave));
    title(strcat(title_str, '输入波形自相关函数'));
    xlabel(texlabel('t/s'));
    ylabel(texlabel('R(t)'));
    axis([-0.012, 0.012, -1.1, 1.1])
    
    saveas(p_xcorr, strcat(path, '\自相关函数输入波形_', title_str, '.png'));
    close(p_xcorr);

    p_xcorr = figure;
    
    plot((maxlags_outWave / fs), R_outWave / max(R_outWave));
    title(strcat(title_str, '输出波形自相关函数'));
    xlabel(texlabel('t/s'));
    ylabel(texlabel('R(t)'));
    axis([-0.012, 0.012, -1.1, 1.1])
    
    saveas(p_xcorr, strcat(path, '\自相关函数输出波形_', title_str, '.png'));
    close(p_xcorr);

    p_xcorr = figure;    % 放大显示，觉得一团糊糊不好看
    
    plot((maxlags_wave / fs), R_wave / max(R_wave));
    title(strcat(title_str, '输入波形自相关函数'));
    xlabel(texlabel('t/s'));
    ylabel(texlabel('R(t)'));
    if strcmp(title_str, '20kHz、50kHz、100kHz三音正弦波')
        axis([-3*(1/(20 * 10 ^ 3)), 3*(1/(20 * 10 ^ 3)), -1.1, 1.1])
    else
        axis([-3*(1/f_wave), 3*(1/f_wave), -1.1, 1.1])
    end

    saveas(p_xcorr, strcat(path, '\自相关函数输入波形2_', title_str, '.png'));
    close(p_xcorr);

    p_xcorr = figure;
    
    plot((maxlags_outWave / fs), R_outWave / max(R_outWave));
    title(strcat(title_str, '输出波形自相关函数'));
    xlabel(texlabel('t/s'));
    ylabel(texlabel('R(t)'));
    if strcmp(title_str, '20kHz、50kHz、100kHz三音正弦波')
        axis([-3*(1/(20 * 10 ^ 3)), 3*(1/(20 * 10 ^ 3)), -1.1, 1.1])
    else
        axis([-3*(1/f_wave), 3*(1/f_wave), -1.1, 1.1])
    end
    
    saveas(p_xcorr, strcat(path, '\自相关函数输出波形2_', title_str, '.png'));
    close(p_xcorr);
