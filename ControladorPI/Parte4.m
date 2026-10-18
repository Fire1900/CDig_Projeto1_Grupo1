% ==============================================================================
% PASSO 4: PROJETO DO CONTROLADOR PI CONTÍNUO NO SISOTOOL (GRUPO 1)
% ==============================================================================
clear; clc; close all;

%% 1. Parâmetros Oficiais Identificados (Modelo P2DZ - Grupo 1)
% Convenção do Roteiro: Tp1 = Lento (ambiente), Tp2 = Rápido (aquecimento)
Kp  = 0.1239;     % Ganho estático do processo (ºC / PWM)
Tp1 = 449.04;    % Constante de tempo LENTA (ambiente) em segundos
Tp2 = 31.96;     % Constante de tempo RÁPIDA (aquecimento) em segundos
Tz  = 367.32;    % Zero térmico em segundos
Td  = 6.67;      % Atraso de transporte (tempo morto) em segundos

%% 2. Especificações de Desempenho (Grupo 1)
Mp_alvo = 0.10;   % Sobrepasso máximo de 10%
Tp_alvo = 25.0;   % Tempo de pico desejado de 25 segundos

%% 3. Cálculo Analítico do Polo Dominante Desejado (s0)
zeta  = -log(Mp_alvo) / sqrt(pi^2 + (log(Mp_alvo))^2); % Fator de amortecimento (~0.5912)
wd    = pi / Tp_alvo;                                  % Freq. amortecida (~0.1257 rad/s)
sigma = (zeta * wd) / sqrt(1 - zeta^2);                % Parte real (~0.0921 rad/s)
s0    = -sigma + 1i*wd;                                % Polo complexo desejado s0

%% 4. Função de Transferência Contínua Gp(s) com Aproximação de Padé
s = tf('s');
KP = 33.2;
KI = KP / Tp2;
Gpi = (s+0.025)/s;
Gp = Kp * (Tz*s + 1) / ((Tp1*s + 1) * (Tp2*s + 1));
set(Gp, 'InputDelay', Td);

% Aproximação de Padé de 1ª ordem para o atraso Td (exigido pelo SISOTOOL)
Gp_pade = pade(Gp, 1);

%% 5. Análise do Condicionamento de Fase e Sugestão do Zero do PI
% Malha aberta com o Integrador na Origem (C_I = 1/s)
G_com_I = Gp_pade / s;
fase_G_I = angle(evalfr(G_com_I, s0)) * (180/pi);

% Avanço de fase necessário que o zero do PI deve fornecer em s0
fase_zero_PI = -180 - fase_G_I;
fase_zero_PI = mod(fase_zero_PI + 180, 360) - 180;

% Zero do PI posicionado para cancelar o polo rápido de aquecimento (Tp2 = 31.96 s)
z_PI = 1 / Tp2; % s = -0.0313 rad/s

%% 6. Exibição dos Resultados e Abertura do SISOTOOL
fprintf('=======================================================\n');
fprintf('     ESPECIFICAÇÕES E POLO DOMINANTE DESEJADO (s0)     \n');
fprintf('=======================================================\n');
fprintf('Fator de Amortecimento (zeta): %.4f\n', zeta);
fprintf('Frequência Amortecida (wd):    %.4f rad/s\n', wd);
fprintf('Parte Real (sigma):            %.4f rad/s\n', sigma);
fprintf('Polo Dominante Desejado (s0):  %.4f + j*%.4f\n', real(s0), imag(s0));
fprintf('-------------------------------------------------------\n');
fprintf('Fase do Sistema com Integrador em s0 : %.2f°\n', fase_G_I);
fprintf('Avanço de Fase necessário do Zero   : %.2f°\n', fase_zero_PI);
fprintf('Zero do PI sugerido (Cancela Tp2)   : s = -%.4f\n', z_PI);
fprintf('=======================================================\n\n');

fprintf('Polo 1: %.4f\n', 1/Tp1);
fprintf('Polo 2: %.4f\n', 1/Tp2);
fprintf('Zero: %.4f\n', 1/Tz);
fprintf('Atraso Polo e Zero: %.4f\n\n',2/Td);

fprintf('Abrindo o Control System Designer (SISOTOOL) no Plano S...\n');
sisotool(Gp_pade);
