import { Application } from "@hotwired/stimulus"
import BatchActionsController from "godmin/controllers/batch_actions_controller"
import DatetimepickerController from "godmin/controllers/datetimepicker_controller"
import NavigationController from "godmin/controllers/navigation_controller"

const application = Application.start()

application.register("batch-actions", BatchActionsController)
application.register("datetimepicker", DatetimepickerController)
application.register("navigation", NavigationController)
