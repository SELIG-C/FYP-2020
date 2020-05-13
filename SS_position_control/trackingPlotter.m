figure('name','Heave Velocity Tracking')
plot(referenceVelocity.Time,referenceVelocity.Data(:,3))
hold on
plot(floatVelocity.Time,floatVelocity.Data(:,3))
legend('Float Velocity','Reference Velocity')   
title('Heave Velocity Tracking')
xlabel('Time(s)')
ylabel('Velocity(m/s)')