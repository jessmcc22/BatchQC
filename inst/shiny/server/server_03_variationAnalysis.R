### VARIATION ANALYSIS TAB ###

## Update covariate options to only those that are not confounded with batch
observeEvent(input$variation_batch, {
    req(reactivevalue$se, input$variation_batch)
    covariate_choices <- covariates_not_confounded(reactivevalue$se,
        input$variation_batch)
    updateSelectizeInput(session = session, inputId = "variation_condition",
        choices = covariate_choices, selected = NULL)
})

## Display variation and p-value plots and tables
observeEvent(input$variation, {
    req(input$variation_batch,
        input$variation_assay, reactivevalue$se)
    withBusyIndicatorServer("variation", {
        tryCatch({
            if (is.null(input$variation_condition)) {
                EV_results <- batchqc_explained_variation(se = reactivevalue$se,
                    batch = input$variation_batch,
                    assay_name = input$variation_assay)
            } else {
                EV_results <- batchqc_explained_variation(se = reactivevalue$se,
                    batch = input$variation_batch,
                    condition = input$variation_condition,
                    assay_name = input$variation_assay)
            }
            EV_ratios <- variation_ratios(EV_results$EV_table_ind,
                input$variation_batch)
            EV_residual_ratios <- variation_ratios(EV_results$EV_table_type2,
                input$variation_batch)
        })

        output$EV_show_plot <- renderPlot({
            EV_plotter(EV_results$EV_table_ind)
        })

        output$EV_show_table <- renderDataTable({
            EV_table(EV_results$EV_table_ind)
        })
        output$EV_residual_show_plot <- renderPlot({
            EV_plotter(EV_results$EV_table_type2)
        })

        output$EV_residual_show_table <- renderDataTable({
            EV_table(EV_results$EV_table_type2)
        })

        output$EV_ratio_plot <- renderPlot({
            ratio_plotter(EV_ratios)
        })

        output$EV_ratio_table <- renderDataTable({
            EV_ratios
        })

        output$EV_residual_ratio_plot <- renderPlot({
            ratio_plotter(EV_residual_ratios)
        })

        output$EV_residual_ratio_table <- renderDataTable({
            EV_residual_ratios
        })
    })
})
