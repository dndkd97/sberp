from django.contrib import admin
from .models import ApplicantStatusLog


@admin.register(ApplicantStatusLog)
class ApplicantStatusLogAdmin(admin.ModelAdmin):
    list_display = ('date', 'status', 'count')