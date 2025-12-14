import random
import time
from statistics import mean
import matplotlib.pyplot as plt


# ============= Общий алгоритм поиска медианы через массив =============

def find_median_value_from_array(arr):
    n = len(arr)
    if n == 0:
        return None
    tmp = sorted(arr)
    if n % 2 == 0:
        return None
    median_index = n // 2
    return tmp[median_index]


# ================== ВАРИАНТ 1: ARRAYLIST (list) ==================

def remove_median_from_array(arr):
    median = find_median_value_from_array(arr)
    if median is None:
        return None, arr.copy()
    tmp = arr.copy()
    for i, x in enumerate(tmp):
        if x == median:
            del tmp[i]
            break
    return median, tmp


# ============ ВАРИАНТ 2: СВЯЗАННЫЙ СПИСОК (LinkedList) ============

class Node:
    __slots__ = ("value", "next")

    def __init__(self, value, next_node=None):
        self.value = value
        self.next = next_node


class LinkedList:
    def __init__(self):
        self.head = None
        self.size = 0

    @classmethod
    def from_iterable(cls, iterable):
        ll = cls()
        for x in iterable:
            ll.push_front(x)
        return ll

    def push_front(self, value):
        new_node = Node(value, self.head)
        self.head = new_node
        self.size += 1

    def remove_first_value(self, value):
        prev = None
        cur = self.head
        while cur is not None:
            if cur.value == value:
                if prev is None:
                    self.head = cur.next
                else:
                    prev.next = cur.next
                self.size -= 1
                return True
            prev = cur
            cur = cur.next
        return False


def remove_median_from_linked_list(ll: LinkedList):
    arr = []
    cur = ll.head
    while cur is not None:
        arr.append(cur.value)
        cur = cur.next

    median = find_median_value_from_array(arr)
    if median is None:
        return None, ll

    ll.remove_first_value(median)
    return median, ll


# =================== Общие замеры и единая таблица ===================

def measure_for_size(n, repeats=3):
    times_array = []
    times_linked = []

    for _ in range(repeats):
        data = [random.randint(-10**9, 10**9) for _ in range(n)]

        start = time.perf_counter()
        median1, new_list = remove_median_from_array(data)
        end = time.perf_counter()
        times_array.append(end - start)

        ll = LinkedList.from_iterable(data)
        start = time.perf_counter()
        median2, new_ll = remove_median_from_linked_list(ll)
        end = time.perf_counter()
        times_linked.append(end - start)

    return mean(times_array), mean(times_linked)


def main():
    sizes = [101, 1000, 10001, 100000, 1000001]
    repeats = 3

    print("Алгоритм: поиск и удаление медианного элемента (при наличии).")
    print("Медиана существует только при НЕЧЁТНОМ числе элементов.")
    print()
    print("Структуры данных:")
    print("1) Python list — аналог динамического массива (ArrayList).")
    print("2) Самописный односвязный список (LinkedList).")
    print()
    print(f"Повторов для усреднения времени: {repeats}")
    print()
    print(f"{'N':>10} | {'list, s':>10} | {'LinkedList, s':>15}")
    print("-" * 42)

    times_list = []
    times_linked = []

    for n in sizes:
        avg_array, avg_linked = measure_for_size(n, repeats=repeats)
        times_list.append(avg_array)
        times_linked.append(avg_linked)
        print(f"{n:10d} | {avg_array:10.6f} | {avg_linked:15.6f}")

    # =================== построение графика T(N) ===================
    plt.figure(figsize=(8, 5))
    plt.plot(sizes, times_list, marker='o', label='list (ArrayList)')
    plt.plot(sizes, times_linked, marker='s', label='LinkedList')
    plt.xscale('log')
    plt.yscale('log')
    plt.xlabel('N (размер структуры)')
    plt.ylabel('T (секунды)')
    plt.title('Зависимость времени работы T от размера N')
    plt.legend()
    plt.grid(True, which='both', linestyle='--', linewidth=0.5)
    plt.tight_layout()
    plt.savefig('median_time_vs_n.png')


if __name__ == "__main__":
    main()
