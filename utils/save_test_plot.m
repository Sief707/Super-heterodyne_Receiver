function save_test_plot(test_name, figure_name)

folder = "results/" + test_name;

if ~exist(folder,"dir")
    mkdir(folder)
end

filename = folder + "/" + figure_name + ".png";

saveas(gcf, filename)

end