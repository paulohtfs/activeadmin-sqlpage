require "activeadmin/sqlpage/version"

module ActiveAdmin
  module SqlPage
    class << self

      def register
        ActiveAdmin.register_page "SQL" do


          menu priority: 1, label: "SQL"

          content title: "SQL" do

            columns do
              column do

                form action: admin_sql_query_path, method: :post do |f|
                  div class: :table_tools do
                    input type: :hidden,
                      name: :authenticity_token,
                      value: form_authenticity_token

                    textarea name: :sql,
                      onkeypress: %{
                        if(event.keyCode==10||(event.ctrlKey && event.keyCode==13)) {
                          $('form').submit();
                        }
                      }, autofocus: 1, title: 'Ctrl+Enter' do
                      params[:sql]
                    end

                    button :submit, title: 'Ctrl+Enter'
                  end
                end

                unless params[:sql].nil?

                  begin
                    result = ActiveRecord::Base.connection.execute( params[:sql] )
                    if result
                      result = ActiveRecord::Result.new(result.fields, result.to_a)
                    end
                  rescue Exception => e
                    result = ActiveRecord::Result.new( [:error], [[e.message]] )
                  end

                  unless result.nil?
                    table class: 'index_table index' do
                      thead do
                        tr do
                          result.columns.each do |name|
                            th name, class: :col
                          end
                        end
                      end
                      tbody do
                        result.rows.each_with_index do |col,i|
                          tr class: (0==i%2?'odd':'even') do
                            col.each do |val|
                              td val, class: :col
                            end
                          end
                        end
                      end
                    end
                  end

                end

              end
            end

          end

          page_action :query, method: :post do
            render action: :index, layout: false
          end


        end
      end

    end
  end
end
