module Api
  module V1
    class NotificationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_notification, only: [ :mark_read ]

      MAX_NOTIFICATIONS = 50

      # GET /api/v1/notifications
      def index
        notifications = current_user.notifications.recent.limit(MAX_NOTIFICATIONS)
        unread_count = current_user.notifications.unread.count

        render_success({
          notifications: notifications.map { |n| serialize_notification(n) },
          unread_count: unread_count
        })
      end

      # PATCH /api/v1/notifications/:id/read
      def mark_read
        @notification.update!(read: true)
        render_success(serialize_notification(@notification), "Notification marked as read")
      rescue ActiveRecord::RecordInvalid => e
        render_error("Failed to mark notification as read", :unprocessable_entity, e.message)
      end

      # POST /api/v1/notifications/mark_all_read
      def mark_all_read
        current_user.notifications.unread.update_all(read: true)
        render_success(nil, "All notifications marked as read")
      end

      # DELETE /api/v1/notifications/:id
      def destroy
        notification = current_user.notifications.find(params[:id])
        notification.soft_delete
        render_success(nil, "Notification deleted")
      rescue ActiveRecord::RecordNotFound
        render_error("Notification not found", :not_found)
      end

      # DELETE /api/v1/notifications
      def destroy_all
        current_user.notifications.update_all(deleted_at: Time.current)
        render_success(nil, "All notifications cleared")
      end

      private

      def set_notification
        @notification = current_user.notifications.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error("Notification not found", :not_found)
      end

      def serialize_notification(notification)
        {
          id: notification.id,
          type: notification.notification_type,
          title: notification.title,
          message: notification.message,
          priority: notification.priority,
          read: notification.read,
          data: notification.data,
          created_at: notification.created_at
        }
      end
    end
  end
end
