clear; close all; clc

import comm.QPSKModulator;
import comm.QPSKDemodulator;

fft_size = 8;
N = 16;

% Generate Twiddle Factors
twiddles = generate_twiddle_factors(N);
fixed_twiddles = convert_to_fixed_point(twiddles);
disp('Fixed-point Twiddle Factors:');
display_fixed_complex(fixed_twiddles);

% Generate random input bits of size 2*fft_size
input_bits = randi([0 1], 1, 2*fft_size);

% Generate LTE signal samples
LTE_signal = generate_LTE_signal(input_bits, fft_size);
%disp('Generated LTE signal samples:');
%disp(LTE_signal.');

% Convert LTE signal to fixed-point
fixed_point_signal = convert_to_fixed_point(LTE_signal);
disp('INPUT: Fixed-point LTE time samples:');
display_fixed_complex(fixed_point_signal);


% Receive LTE signal samples
LTE_subcarriers = receive_LTE_signal(double(fixed_point_signal), fft_size);
disp('OUTPUT: Fixed-point LTE subcarriers:');
display_fixed_complex(LTE_subcarriers);


output_bits = demodulate_LTE_signal(LTE_subcarriers);


function LTE_signal = generate_LTE_signal(bits, fft_size)
    % Modulation scheme (QPSK)
    modulation_order = 4; % QPSK
    modulator = comm.QPSKModulator('BitInput', true, 'PhaseOffset', pi/4, 'SymbolMapping', 'Gray');
    symbols = step(modulator, bits.');

    % Reshape the symbols into a matrix for IFFT
    symbols_matrix = reshape(symbols, [], fft_size);

    % Perform IFFT
    time_domain_signal = ifft(symbols_matrix);

    % Output vector of LTE signal samples
    LTE_signal = time_domain_signal(:).';
end

function LTE_subcarriers = receive_LTE_signal(LTE_signal, fft_size)
    % Reshape the LTE signal into a matrix for FFT
    signal_matrix = reshape(LTE_signal, fft_size, []);

    % Perform FFT
    frequency_domain_signal = fft(signal_matrix);

    LTE_subcarriers = frequency_domain_signal(:);
end

function output_bits = demodulate_LTE_signal(subcarriers)
    % Demodulation scheme (QPSK)
    demodulator = comm.QPSKDemodulator('BitOutput', true, 'PhaseOffset', pi/4, 'SymbolMapping', 'Gray');
    demodulated_symbols = step(demodulator, subcarriers);

    % Display the output bits
    disp('Output bits:');
    disp(demodulated_symbols.');

    output_bits = demodulated_symbols.';
end

function fixed_point_signal = convert_to_fixed_point(LTE_signal)
    % Create a fixed-point data type with 1 sign bit, 9 integer bits, and 6 fractional bits
    T = numerictype('WordLength', 16, 'FractionLength', 6, 'Signed', true);

    % Convert the LTE signal to fixed-point
    fixed_point_signal = fi(LTE_signal, T);
end

function display_fixed_complex(complex_signal)
    % Display the fixed-point signal with 6 decimal places
    for i = 1:length(complex_signal)
        fprintf('%.6f + %.6fi\n', real(complex_signal(i)), imag(complex_signal(i)));
    end
end

function twiddles = generate_twiddle_factors(N)
    twiddles = complex(zeros(1, N/2));
    for i = 1:N/2
        theta = 2.0 * pi * (i-1) / N;
        twiddles(i) = cos(theta) - 1i*sin(theta);
    end
end

