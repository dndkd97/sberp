from django.db import models


class ApplicantStatusLog(models.Model):
    date = models.DateField(verbose_name="집계일")
    status = models.CharField(
        max_length=50,
        verbose_name="전형상태"
    )
    count = models.IntegerField(
        default=0,
        verbose_name="지원자 수"
    )

    def __str__(self):
        return f"[{self.date}] {self.status} : {self.count}명"