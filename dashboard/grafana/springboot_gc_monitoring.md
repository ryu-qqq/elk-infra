<details>
<summary>JVM GC Pause 모니터링</summary>
# 📌 JVM GC Pause 모니터링

## 📊 PromQL 쿼리
### **1. GC Pause 발생 횟수 변화율 (GC Pause Count Rate)**
```promql
irate(jvm_gc_pause_seconds_count{instance="$instance", application="$application"}[5m])
```
✔ **JVM에서 발생한 GC Pause(정지) 이벤트 횟수의 변화율.**  
✔ **이 값이 증가하면, GC가 자주 실행되며 애플리케이션이 정지(Pause)하는 빈도가 증가한 것.**  
✔ **GC Pause가 자주 발생하면, 애플리케이션의 응답 시간이 느려질 가능성이 있음.**  
✔ **특히, Full GC가 많이 발생하면 심각한 성능 저하로 이어질 수 있음.**

### **2. GC Pause 총 시간 변화율 (GC Pause Duration Rate)**
```promql
irate(jvm_gc_pause_seconds_sum{instance="$instance", application="$application"}[5m])
```
✔ **JVM에서 발생한 GC Pause(정지) 총 시간의 변화율.**  
✔ **GC Pause의 지속 시간이 길수록, 애플리케이션의 처리 성능에 부정적인 영향을 미칠 수 있음.**  
✔ **이 값이 높아지면, GC 튜닝이 필요할 가능성이 있음 (예: Heap 크기 조정, GC 알고리즘 변경 등).**  
✔ **GC Pause 총 시간이 길다면, 애플리케이션의 전체적인 성능이 저하될 수 있음.**

---

## 🔍 설명
| **쿼리** | **설명** |
|----------|---------|
| `jvm_gc_pause_seconds_count` | GC Pause 발생 횟수 |
| `jvm_gc_pause_seconds_sum` | GC Pause 지속 시간 (초) |

📌 **GC Pause는 JVM이 객체 정리(Garbage Collection)를 수행할 때 애플리케이션이 멈추는 시간임.**  
📌 **Pause 횟수가 많아지면, GC가 너무 자주 발생하여 성능 저하를 유발할 수 있음.**  
📌 **Pause 시간이 길면, Major GC(Full GC) 발생 가능성이 높으며 응답 속도가 저하될 수 있음.**

---

## 🔥 **왜 이 2개의 메트릭이 중요한가?**
✔ **GC Pause 횟수만 보면 안 되는 이유**
- GC Pause가 자주 발생하더라도 Pause 시간이 짧으면 큰 문제가 되지 않을 수 있음.
- 따라서 **Pause 지속 시간과 함께 모니터링하여 실제 영향을 평가해야 함.**

✔ **GC Pause 총 시간을 모니터링하는 이유**
- Pause 시간이 길수록 **애플리케이션이 응답하지 않는 시간이 늘어나며, 성능 저하가 발생할 가능성이 높음.**
- Minor GC는 보통 빠르게 끝나지만, **Full GC가 발생하면 애플리케이션이 수 초간 멈출 수도 있음.**
- GC Pause 시간이 높다면, **Heap 크기 조정, GC 알고리즘 변경(G1 GC, ZGC 등)이 필요할 가능성이 있음.**

✔ **Pause 횟수와 총 시간을 함께 보면 GC 최적화 가능**
- **Pause 횟수는 많지만 총 시간이 짧다면, GC는 자주 실행되지만 빠르게 완료되는 상태.**
- **Pause 횟수와 총 시간이 모두 많다면, GC가 시스템에 큰 부하를 주고 있는 상태.**
- **Pause 횟수는 적지만 총 시간이 길다면, Full GC가 자주 발생할 가능성이 높음.**

---

## 📌 **Grafana에서 JVM GC Pause 모니터링 대시보드 설정**
### 🖥️ **패널 설정**
- **패널 유형:** Line Chart
- **X축:** 시간 (Timestamp)
- **Y축:** GC Pause 횟수 또는 지속 시간 (Count / Seconds)
- **PromQL 쿼리:**
    - **GC Pause 발생 횟수**
      ```promql
      irate(jvm_gc_pause_seconds_count{instance="$instance", application="$application"}[5m])
      ```
    - **GC Pause 총 시간**
      ```promql
      irate(jvm_gc_pause_seconds_sum{instance="$instance", application="$application"}[5m])
      ```

### 🚨 **임계값(Threshold) 설정**
- **Pause 횟수가 급격히 증가** → 🟠 **주의 (GC 최적화 필요 가능성)**
- **Pause 시간이 1초 이상 지속** → 🔴 **위험 (Full GC 가능성 증가, 애플리케이션 응답 지연)**
- **Pause 시간이 지속적으로 증가** → 🟠 **Heap 크기 조정 또는 GC 알고리즘 변경 검토 필요**

📌 **GC Pause가 많으면, GC 튜닝을 통해 Young Generation 크기 조정이 필요할 수 있음!**  
📌 **Full GC가 자주 발생하면, GC 알고리즘 변경(G1 GC, ZGC 등)을 고려해야 함!**

---

## ✅ **결론**
✔ **GC Pause 횟수와 총 시간을 함께 보면 JVM의 Garbage Collection 성능을 평가할 수 있음!**  
✔ **Pause 횟수가 많으면 Minor GC가 자주 발생하는 상태, 최적화가 필요할 가능성이 있음!**  
✔ **Pause 시간이 길다면 Full GC가 자주 발생할 가능성이 있으며, 심각한 성능 저하 가능성이 있음!**  
✔ **Grafana에서 GC Pause 모니터링을 통해 애플리케이션의 응답 속도를 최적화할 수 있음!**

</details>