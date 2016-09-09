# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'import', :to => 'import#index'
get 'import/run', :to => 'import#run'
