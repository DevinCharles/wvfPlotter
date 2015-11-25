% Copyright (C) 2015  Devin C Prescott
function h = derivative(t,y,a,b,order)
        
    dt = diff(t(a:b));
    dy = diff(y(a:b));
    
    if order > 1
        dy = diff(dy);
    end
    
    if order == 3
        dy = diff(dy);
    end
    
    dy = [repmat(dy(1),order,1);dy];
    dt = [dt(1);dt];
    dydt = dy./dt;
    
    figure
    
    h(1) = subplot(1,2,1,'ButtonDownFcn',@MarkerLineDelete);
    plot(t(a:b),y(a:b),'ButtonDownFcn',@MarkerLineCallback)
    grid minor
    
    h(2) = subplot(1,2,2,'ButtonDownFcn',@MarkerLineDelete);
    plot(t(a:b),dydt,'ButtonDownFcn',@MarkerLineCallback)
    grid minor
    
    linkaxes(h,'x')
    
%     var_name = strcat('d',num2str(order),'ydt',num2str(order));
    assignin('base','dydt',dydt)
end