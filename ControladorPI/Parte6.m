% 1. Atribuição dos Parâmetros Identificados na Coleta Oficial
Kp  = 0.1239;     % Ganho estático
Tp1 = 449.04;     % Polo lento de resfriamento ambiente (s)
Tp2 = 31.96;      % Polo rápido de aquecimento (s)
Tz  = 367.32;     % Zero térmico (s)
Td  = 6.67;       % Atraso de transporte (s)


% 2. Período de Amostragem do Controle Digital (Ts = Td / 2)
Ts = Td / 2;      % Ts = 3.335 s
fprintf('Período de amostragem discreto definido: Ts = %.3f s\n', Ts);


% 3. Função de Transferência Contínua G(s)
s = tf('s');
Gp = Kp * (Tz*s + 1) / ((Tp1*s + 1) * (Tp2*s + 1)); % Garanta o '' entre Tz e s
set(Gp, 'InputDelay', Td);


% 4. Aproximação de Padé de 1ª Ordem para o Atraso Td = 6.67 s (Exigido pelo sisotool)
Gp_pade = pade(Gp, 1);


% 5. Discretização ZOH no Período Ts = 3.335 s
Gz = c2d(Gp_pade, Ts, 'zoh');


fprintf('\nFunção de Transferência Discreta G(z):\n');
disp(Gz);


% 6. Abrir o Control System Designer (SISOTOOL)
fprintf('\nAbrindo o SISOTOOL...\n');
sisotool(Gz);