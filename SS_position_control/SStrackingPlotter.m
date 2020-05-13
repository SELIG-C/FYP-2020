figure
plot(refV)
hold on
plot(surgeV)
xlabel('Time (s)')
ylabel('Velocity (m/s)')
legend('Reference velocity','Float velocity')
title('Velocity tracking in Heave for SS Model')